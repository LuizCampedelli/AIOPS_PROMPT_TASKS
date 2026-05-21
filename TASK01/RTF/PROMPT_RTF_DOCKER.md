# Role
Act as an specialized senior devops engineer, focused in docker, kubernetes, python as script language.

# Task
Create a dockerfile, to enable the python script, in api/flask, in port 8080, using dependencies in requirements.txt, declared bellow, adding two environement variables, DATABASE_URL & API_KEY.

requirements.txt content:
Flask==3.0.0
gunicorn==21.2.0
requests==2.31.0
python-dotenv==1.0.0
psycopg2-binary==2.9.9

In production, the service will run in gunicorn --bind 0.0.0.0:8080 --workers 4 app:app

# Format
Create a complet python script and dockerfile, that will apply this script, script format bellow, add variables of the project and explanation in the top of file, create an EXPLANATION.md, inside RTF Folder, with the guidelines to apply the project files.

Project script format:

lift/
├── app.py
├── requirements.txt
├── lib/
│   ├── auth.py
│   └── storage.py
└── tests/
    └── test_app.py
