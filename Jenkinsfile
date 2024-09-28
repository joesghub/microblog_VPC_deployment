pipeline {
  agent any
    stages {
        stage ('Build') {
            steps {
                sh '''#!/bin/bash
                python3.9 -m venv venv
                source venv/bin/activate
                pip install pip --upgrade
                pip install -r requirements.txt
                pip install gunicorn pymysql cryptography nginx
                FLASK_APP=microblog.py
                flask translate compile
                flask db upgrade
                '''
            }
        }
        stage ('Test') {
            steps {
                sh '''#!/bin/bash
                source venv/bin/activate
                gunicorn -b :5000 -w 4 microblog:app &
                GUNICORN_PID=$!
                py.test ./tests/unit/ --verbose --junit-xml test-reports/results.xml
                chmod +x tests/unit/test_app.py
                chmod +x /var/lib/jenkins/workspace/microblog_prac_main/tests/unit/test_app.sh
                python tests/unit/test_app.py
                '''
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }
        stage ('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage ('Deploy') {
              steps {
                  sh '''#!/bin/bash
                  BUILD_ID=stayAlive 
                  source venv/bin/activate
                  mkdir -p /home/ubuntu/scripts
                  curl -o /home/ubuntu/scripts/setup.sh URL
                  chmod +x /home/ubuntu/scripts/setup.sh
                  ./home/ubuntu/scripts/setup.sh
                  '''
              }
          }
      }
  }
