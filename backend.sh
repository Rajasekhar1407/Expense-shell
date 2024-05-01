#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then
    echo -e "$R Please run the script with root access $N"
    exit 1
else
    echo -e "$G You are Super User $N"
fi

VALIDATE() {
    if [$? -ne 0]
    then
        echo -e "$R $2...FAILED $N"
    else
        echo -e "$G $2...SUCCESS $N"
    fi
}

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enable nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [$? -ne 0]
then
    useradd expense
    VALIDATE $? "Creating Expense user"
else
    echo -e "Expense user already created ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracting backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs Dependencies"

cp C:\devops\repos\expense-shell\backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copieing backend service"

systemctl demon-reload 
VALIDATE $? "Demon Reload"

systemctl start backend
VALIDATE $? "Starting backend service"

systemctl enable backend
VALIDATE $? "Enabling backend service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Client"

echo "Please enter DB password"
read -s mysql_root_password

mysql -h db.rajasekhar.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema Loading"

systemctl restart backend
VALIDATE $? "Restarting backend service"