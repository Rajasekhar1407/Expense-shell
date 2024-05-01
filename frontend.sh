echo "Test"

dnf install nginx -y

systemctl enable nginx

systemctl start nginx

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip

cd /usr/share/ngix/html

unzip /tmp/frontend.zip

cp C:\devops\repos\expense-shell\expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx