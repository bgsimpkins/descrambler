import os
import json
from flask import Flask, render_template, request, url_for
from dotenv import load_dotenv
import uuid

app = Flask(__name__)


@app.route('/descrambler_service', methods=['GET','POST'])
def descrambler_service():
    if request.args.get('request') == "getScrambleSolution":
        #print('something')
        scramble = request.args.get('scrambleProblem')
        print('scrambleProblem={}'.format(scramble))
        id = str(uuid.uuid4())
        print('id={}'.format(id))
        com = "R_LIBS_USER=~/R/lib/ Rscript descrambler.R --scramble {scramble} --id {id}".format(scramble=scramble,id=id)
        os.system(com)

        filename = 'descrambleResults_{}.txt'.format(id)
        with open(filename) as f:
            d = json.load(f)
            return d

        os.remove(filename)
    else:
        print('Nothing to process. Are you simple??')
        return 'You are a simple person!'

    return 'yep'


@app.route('/descrambler', methods=['GET','POST'])
def descrambler_app():
    pass


if __name__ == '__main__':
    load_dotenv(override=False)
    print('Starting web app..')
    app.run(
        host="0.0.0.0",
        port=5002,
        debug=True,
        use_reloader=False
    )