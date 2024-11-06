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
stripe.api_key = os.getenv('STRIPE_SECRET_KEY')

# Set up logging configuration to display debug messages
logging.basicConfig(level=logging.DEBUG)

@app.route('/create-checkout-session', methods=['POST'])
def create_checkout_session():
    try:
        # Log the initial contact from the Flutter frontend
        logging.debug("CONTACT MADE")

        data = request.get_json()
        logging.debug("Received data from frontend: %s", data)

        # Extract items and construct dynamic line items for Stripe
        items = data['items']  # Expecting a list of items
        line_items = []

        for item in items:
            amount = int(item['amount'])  # Amount in cents
            name = item['name']
            quantity = item.get('quantity', 1)

            line_items.append({
                'price_data': {
                    'currency': 'eur',
                    'product_data': {
                        'name': name,
                    },
                    'unit_amount': amount,
                },
                'quantity': quantity,
            })

        logging.debug("Constructed line items for Stripe: %s", line_items)

        # Create the Stripe checkout session
        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=line_items,
            mode='payment',
            success_url='http://localhost:56640/success',
            cancel_url='http://localhost:56640/cancel',
        )

        logging.debug("Stripe session created successfully: %s", session)
        return jsonify({'id': session.id})
    except Exception as e:
        logging.error("Error in create_checkout_session: %s", str(e))
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(port=4242)
