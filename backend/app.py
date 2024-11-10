# app.py
# Do not remove this comment text when giving me the new code.

from flask import Flask, request, jsonify, send_file, make_response
from flask_cors import CORS
import stripe
import os
import logging
from dotenv import load_dotenv
from datetime import datetime
import json
import base64
import google.auth.transport.requests
import google.oauth2.id_token

# Load environment variables from a .env file
load_dotenv()

app = Flask(__name__)

# Enable CORS for all routes (for development purposes)
CORS(app, resources={r"/*": {"origins": "*"}})

# Set your Stripe secret key from environment variables
stripe.api_key = os.getenv('STRIPE_LIVE_SECRET_KEY') if os.getenv(
    "FLASK_ENV") == "production" else os.getenv('STRIPE_TEST_SECRET_KEY')

# Set up logging configuration to display debug messages
logging.basicConfig(level=logging.DEBUG)

# Placeholder for in-memory orders database; replace with persistent DB for production
orders_db = {}

# Directory to store uploaded images
IMAGES_DIR = './images'
if not os.path.exists(IMAGES_DIR):
    os.makedirs(IMAGES_DIR)

# Admin email
ADMIN_EMAIL = 'novahutskl@gmail.com'

def verify_id_token(id_token):
    try:
        request_adapter = google.auth.transport.requests.Request()
        id_info = google.oauth2.id_token.verify_oauth2_token(
            id_token, request_adapter, None)
        return id_info
    except Exception as e:
        logging.error("Error verifying ID token: %s", str(e), exc_info=True)
        return None

def authenticate_request():
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Bearer '):
        logging.error("Invalid authorization header.")
        return None

    id_token = auth_header.split('Bearer ')[1]
    id_info = verify_id_token(id_token)
    if id_info:
        user_email = id_info.get('email')
        return user_email
    else:
        return None

@app.route('/create-checkout-session', methods=['POST'])
def create_checkout_session():
    try:
        user_email = authenticate_request()
        if not user_email:
            return jsonify({'error': 'Unauthorized'}), 401

        logging.debug("User authenticated: %s", user_email)

        data = request.get_json()
        logging.debug("Received data from frontend: %s", data)

        items = data['items']
        address = data.get('address', {})
        stickers = data.get('stickers', [])
        order_number = os.urandom(5).hex().upper()  # Generate unique order number
        order_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        line_items = []

        for item in items:
            amount = int(item['amount'])
            name = item['name']
            quantity = item.get('quantity', 1)

            line_items.append({
                'price_data': {
                    'currency': 'eur',
                    'product_data': {'name': name},
                    'unit_amount': amount,
                },
                'quantity': quantity,
            })

        # Add a shipping fee of 4.90 EUR (490 cents)
        line_items.append({
            'price_data': {
                'currency': 'eur',
                'product_data': {'name': 'Shipping'},
                'unit_amount': 490,
            },
            'quantity': 1,
        })

        logging.debug("Constructed line items for Stripe: %s", line_items)

        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=line_items,
            mode='payment',
            shipping_address_collection={
                'allowed_countries': ['US', 'CA', 'DE', 'AT'],
            },
            success_url=f'http://localhost:56640/success#/dashboard?order_number={order_number}&address={address}',
            cancel_url='http://localhost:56640/cancel',
        )

        # Calculate total price in cents
        total_price_cents = sum(
            item['amount'] * item.get('quantity', 1) for item in items) + 490  # Total with shipping

        # Save images to the server and replace image data with image IDs
        for idx, sticker in enumerate(stickers):
            image_data_base64 = sticker.get('imageData', '')
            if image_data_base64:
                image_data = base64.b64decode(image_data_base64)
                image_id = f"{order_number}_{idx}"
                image_path = os.path.join(IMAGES_DIR, f"{image_id}.png")
                with open(image_path, 'wb') as f:
                    f.write(image_data)
                sticker['image_id'] = image_id
                logging.debug("Saved image for sticker %s at %s", image_id, image_path)
                logging.debug(
                    "Sticker %s details: size=%s, quantity=%s, price=%s",
                    image_id, sticker.get('size'), sticker.get('quantity'), sticker.get('price')
                )
                # Remove 'imageData' to reduce storage size
                sticker.pop('imageData', None)
            else:
                logging.warning("No image data for sticker index %s", idx)

        # Save order to in-memory database
        orders_db[order_number] = {
            'order_number': order_number,
            'user_email': user_email,
            'order_date': order_date,
            'total_price': total_price_cents,  # Store in cents
            'address': address,
            'items': stickers,  # Store stickers with image IDs
            'status': 0,  # Default to "payment" status
            'allow_edit': True,
        }

        logging.debug("Order saved: order number %s by user %s", order_number, user_email)

        return jsonify({'id': session.id, 'order_number': order_number, 'address': address, 'items': stickers})
    except Exception as e:
        logging.error("Error in create_checkout_session: %s", str(e), exc_info=True)
        return jsonify({'error': str(e)}), 400

@app.route('/orders', methods=['GET'])
def get_orders():
    user_email = authenticate_request()
    if not user_email:
        return jsonify({'error': 'Unauthorized'}), 401

    logging.debug("User authenticated: %s", user_email)

    if user_email == ADMIN_EMAIL:
        # Return all orders for admin
        logging.debug("All orders retrieved for admin")
        return jsonify(list(orders_db.values()))
    else:
        user_orders = [order for order in orders_db.values() if order['user_email'] == user_email]
        logging.debug("Orders retrieved for user: %s", user_email)
        return jsonify(user_orders)

@app.route('/order/<order_number>', methods=['GET'])
def get_order(order_number):
    user_email = authenticate_request()
    if not user_email:
        return jsonify({'error': 'Unauthorized'}), 401

    logging.debug("User authenticated: %s", user_email)

    order = orders_db.get(order_number)
    if order:
        if user_email == ADMIN_EMAIL or order['user_email'] == user_email:
            logging.debug("Order retrieved for order number: %s", order_number)
            return jsonify(order)
        else:
            return jsonify({'error': 'Forbidden'}), 403
    else:
        logging.error("Order not found for order number: %s", order_number)
        return jsonify({'error': 'Order not found'}), 404

@app.route('/download-image/<image_id>', methods=['GET'])
def download_image(image_id):
    try:
        user_email = authenticate_request()
        if not user_email:
            return jsonify({'error': 'Unauthorized'}), 401

        logging.debug("User authenticated: %s", user_email)

        image_path = os.path.join(IMAGES_DIR, f'{image_id}.png')
        if os.path.exists(image_path):
            # Check if the user is authorized to access the image
            order_number = image_id.split('_')[0]
            order = orders_db.get(order_number)
            if order and (user_email == ADMIN_EMAIL or order['user_email'] == user_email):
                logging.debug("Image found for download: %s", image_id)
                return send_file(image_path, mimetype='image/png')
            else:
                return jsonify({'error': 'Forbidden'}), 403
        else:
            logging.error("Image not found for download: %s", image_id)
            return jsonify({'error': 'Image not found'}), 404
    except Exception as e:
        logging.error("Error in download_image: %s", str(e), exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/update-order-status', methods=['POST'])
def update_order_status():
    try:
        user_email = authenticate_request()
        if not user_email or user_email != ADMIN_EMAIL:
            return jsonify({'error': 'Unauthorized'}), 401

        logging.debug("Admin authenticated: %s", user_email)

        data = request.get_json()
        order_number = data['order_number']
        new_status = data['status']
        if order_number in orders_db:
            orders_db[order_number]['status'] = new_status
            logging.debug("Order status updated for order number: %s to status %s", order_number, new_status)
            return jsonify({'success': True})
        else:
            logging.error("Order not found for updating status: %s", order_number)
            return jsonify({'error': 'Order not found'}), 404
    except Exception as e:
        logging.error("Error in update_order_status: %s", str(e), exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/delete-order', methods=['POST'])
def delete_order():
    try:
        user_email = authenticate_request()
        if not user_email or user_email != ADMIN_EMAIL:
            return jsonify({'error': 'Unauthorized'}), 401

        logging.debug("Admin authenticated: %s", user_email)

        data = request.get_json()
        order_number = data['order_number']
        if order_number in orders_db:
            # Delete associated images
            order = orders_db[order_number]
            for item in order['items']:
                image_id = item.get('image_id')
                if image_id:
                    image_path = os.path.join(IMAGES_DIR, f'{image_id}.png')
                    if os.path.exists(image_path):
                        os.remove(image_path)
                        logging.debug("Deleted image file: %s", image_path)
            # Delete the order
            del orders_db[order_number]
            logging.debug("Order deleted: %s", order_number)
            return jsonify({'success': True})
        else:
            logging.error("Order not found for deletion: %s", order_number)
            return jsonify({'error': 'Order not found'}), 404
    except Exception as e:
        logging.error("Error in delete_order: %s", str(e), exc_info=True)
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(port=4242)
