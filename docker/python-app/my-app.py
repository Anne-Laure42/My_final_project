from flask import Flask, render_template, request, flash, redirect, url_for

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'

# Exemple de données fictives pour les utilisateurs enregistrés
users = ['Alice', 'Bob', 'Charlie']

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        name = request.form.get('name')
        if not name:
            flash('Name is required!', 'error')
            return redirect(url_for('home'))

        users.append(name)
        flash('User added successfully!', 'success')
        return redirect(url_for('home'))

    return render_template('index.html', users=users)

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/help')
def help():
    return render_template('help.html')


@app.route('/health')
def health():
    return render_template('health.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)
