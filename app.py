import os
from flask import Flask, render_template, request, url_for
from dotenv import load_dotenv

app = Flask(__name__)


@app.route('/descrambler_service', methods=['GET', 'POST'])
def descrambler_service():
    pass
