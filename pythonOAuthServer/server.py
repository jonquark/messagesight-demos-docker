import flask, time, sys, os, signal, random, string, json
from flask import Flask, jsonify, request

app = Flask(__name__)

AppCId = ''
AppSecret = ''
AllowedGType = 'password'
users = []
passwords = []
groups = []
tokens = []
reftokens = []
expires = []
nusers = 0


# Set App configuration data
def setupUserData(config):
    global nusers, AppCId, AppSecret, users, passwords, groups, tokens, reftokens, expires
    AppCId = config['client_id']
    AppSecret = config['client_secret']
    for user in config['users']:
        users.append(user['name'])
        passwords.append(user['password'])
        groups.append(user['groups'])
        tokens.append('')
        reftokens.append('')
        expires.append('')
        nusers += 1
    print("Client ID: ", AppCId)
    print("Client secret: ", AppSecret)
    print("Total users defined: ", nusers)


# Authenticate username/password
def authenticateUser(username, password):
    global nusers, AppCId, AppSecret, users, passwords, groups, tokens, reftokens, expires
    for i in range(nusers):
        if username == users[i] and password == passwords[i]:
            letters = string.ascii_letters
            tokens[i] = ''.join(random.choice(letters) for j in range(32))
            reftokens[i] = ''.join(random.choice(letters) for j in range(32))
            expires[i] = int(time.time()) + 180
            return True, tokens[i], reftokens[i], expires[i]
    return False, None, None, 0


# Verify Token
def verifyToken(token):
    global nusers, AppCId, AppSecret, users, passwords, groups, tokens, reftokens, expires
    retval = ''
    for i in range(nusers):
        if token == tokens[i]:
            user = users[i]
            grps = groups[i]
            expiry = expires[i]
            if expiry > int(time.time()):
                retval = {"scope":grps,"client_id":user,"active":True,"token_type":"Bearer","exp":expiry}
            else:
                retval = {"active":False,"exp":expiry}
            return True, retval
    return False, retval
    

# Returns access token
@app.route('/oauth2/endpoint/PythonOAuthProvider/token', methods = ['POST', 'GET'])
def token():
    global nusers, AppCId, AppSecret, users, passwords, groups, tokens, reftokens, expires
    try:
        gtype = ""
        cid = ""
        secret = ""
        username = ""
        password = ""

        contentType = request.headers.get('Content-Type', None)
        content = None
        if contentType is not None:
            if "x-www-form" in contentType:
                print("Received FORM data")
                content = request.form
            if "json" in contentType:
                print("Received JSON data")
                content = request.json
        else:
            print("Check args for content")
            content = request.args

        if content is not None:
            gtype = content.get('grant_type')
            cid = content.get('client_id')
            secret = content.get('client_secret')
            username = content.get('username')
            password = content.get('password')

        # Verify client secrect
        if (gtype != AllowedGType) or (cid != AppCId) or (secret != AppSecret):
            print("Client verification failed: ", gtype, cid, secret)
            print("Config set to: ", AppCId, AppSecret)
            status_code = flask.Response(status=400)
            return status_code

        # Authenticate user
        auth, token, refresh, expiry = authenticateUser(username, password)
        if auth == False:
            print("User authentication failed: ", username, password)
            status_code = flask.Response(status=401)
            return status_code

        return (jsonify({'access_token':token,'token_type':'Bearer','expires_in':expiry,'scope':'','refresh_token':refresh}))

    except Exception as ex:
        extype, exobj, extb = sys.exc_info()
        print("Exception type: ", extype)
        print("Exception object: ", exobj)
        print("Exception line no: ", extb.tb_lineno)
        status_code = flask.Response(status=400)
        return status_code


# Validates and returns user info
@app.route('/oauth2/endpoint/PythonOAuthProvider/authorize',methods = ['POST', 'GET'])
def authorize():
    global nusers, AppCId, AppSecret, users, passwords, groups, tokens, reftokens, expires
    try:
        access_token = ""
        contentType = request.headers.get('Content-Type', None)
        content = None
        if contentType is not None:
            if "x-www-form" in contentType:
                print("Received FORM data")
                content = request.form
            if "json" in contentType:
                print("Received JSON data")
                content = request.json
        else:
            print("Check args for content")
            content = request.args

        if content is not None:
            access_token = content.get('access_token')

        res, retval = verifyToken(access_token)
        if res == False:
            print("Token verification failed: ", access_token)
            status_code = flask.Response(status=400)
            return status_code

        return (json.dumps(retval))

    except Exception as ex:
        extype, exobj, extb = sys.exc_info()
        print("Exception type: ", extype)
        print("Exception object: ", exobj)
        print("Exception line no: ", extb.tb_lineno)
        status_code = flask.Response(status=400)
        return status_code


# Quit App
@app.route('/oauth2/endpoint/PythonOAuthProvider/quit', methods = ['GET'])
def stopServer():
    os.kill(os.getpid(), signal.SIGINT)
    return jsonify({ "success": True, "message": "Server is shutting down..." })


if __name__ == '__main__':
    with open('./config.json') as configFD:
        config = json.load(configFD)
        print("Read config items ...")
        configFD.close()
        setupUserData(config)

    app.run(host= '0.0.0.0', port=5000, debug = True)


