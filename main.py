from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:rupha@localhost:5432/demo'


db = SQLAlchemy(app)

class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(40))
    dayorder = db.Column(db.Integer)
    ch1 = db.Column(db.String)
    ch2 = db.Column(db.String)
    ch3 = db.Column(db.String)
    ch4 = db.Column(db.String)
    ch5 = db.Column(db.String)

with app.app_context():
    db.create_all()
    
@app.route('/tasks', methods=['GET'])
def get_tasks():
    tasks = Task.query.all()
    task_list = [
        {'id':task.id, 'name':task.name, 'dayorder':task.dayorder, 'ch1':task.ch1, 'ch2':task.ch2, 'ch3':task.ch3, 'ch4':task.ch4, 'ch5':task.ch5} for task in tasks
    ]
    return jsonify({"tasks":task_list})

@app.route('/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    print(data)
    # Check if the name and dayorder already exist in the table
    existing_task = Task.query.filter_by(name=data['name'], dayorder=data['dayorder']).first()
    if existing_task:
        return jsonify({'message': 'Data already exists'}), 200

    new_task = Task(name=data['name'],dayorder=data['dayorder'], ch1=data['ch1'], ch2=data['ch2'], ch3=data['ch3'], ch4=data['ch4'], ch5=data['ch5'])

    db.session.add(new_task)
    db.session.commit()
    return jsonify({'message': 'Data created'}), 200

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    task_to_delete = Task.query.get(task_id)

    if task_to_delete:
        db.session.delete(task_to_delete)
        db.session.commit()
        return jsonify({'message': 'Data deleted'}), 200
    else:
        return jsonify({'message': 'Data not found'}), 404
    
@app.route('/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    task_to_update = Task.query.get(task_id)

    if task_to_update:
        data = request.get_json()
        task_to_update.name = data.get('name', task_to_update.name)
        task_to_update.dayorder = data.get('dayorder', task_to_update.dayorder)
        task_to_update.ch1 = data.get('ch1', task_to_update.ch1)
        task_to_update.ch2 = data.get('ch2', task_to_update.ch2)
        task_to_update.ch3 = data.get('ch3', task_to_update.ch3)
        task_to_update.ch4 = data.get('ch4', task_to_update.ch4)
        task_to_update.ch5 = data.get('ch5', task_to_update.ch5)

        db.session.commit()
        return jsonify({'message': 'Data updated'}), 200
    else:
        return jsonify({'message': 'Data not found'}), 404
    
if __name__ == "__main__":
    print("Starting Flask server...")
    app.run(host='0.0.0.0', port=5000)