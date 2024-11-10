# app.py
# Do not remove this comment text when giving me the new code.

from flask import Flask, request, jsonify
from flask_cors import CORS
import stripe
import os
import logging
from dotenv import load_dotenv

# Load environment variables from a .env file
load_dotenv()

app = Flask(__name__)

# Enable CORS for all routes (for development purposes)
CORS(app, resources={r"/create-checkout-session": {"origins": "*"}})

# Set your Stripe secret key from environment variables
if os.getenv("FLASK_ENV") == "production":
    stripe.api_key = os.getenv('STRIPE_LIVE_SECRET_KEY')
else:
    stripe.api_key = os.getenv('STRIPE_TEST_SECRET_KEY')

# Set up logging configuration to display debug messages
logging.basicConfig(level=logging.DEBUG)

@app.route('/create-checkout-session', methods=['POST'])
def create_checkout_session():
    try:
        logging.debug("CONTACT MADE")

        data = request.get_json()
        logging.debug("Received data from frontend: %s", data)

        items = data['items']
        address = data.get('address', {})
        order_number = os.urandom(5).hex().upper()  # Generate unique order number
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

        # Add a shipping fee of 4.90 EUR
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

        logging.debug("Stripe session created successfully: %s", session)
        return jsonify({'id': session.id, 'order_number': order_number, 'address': address, 'items': items})
    except Exception as e:
        logging.error("Error in create_checkout_session: %s", str(e), exc_info=True)
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(port=4242)
