# webapp-cookbook
chef cookbook for deploying webapp

=============================================

#AWS Environment:

### Access rules:
aws ec2 create-security-group --group-name sec-application --description sec-application  
[note sg-id]  
aws ec2 create-security-group --group-name sec-database --description sec-database  
[note sg-id]  
aws ec2 create-security-group --group-name sec-balancer --description sec-balancer  
[note sg-id]  

aws ec2 authorize-security-group-ingress  --group-name sec-database --source-group sec-application --protocol tcp  --port 3306  
aws ec2 authorize-security-group-ingress --group-name sec-balancer --cidr 0.0.0.0/0 --port 80 --protocol tcp  
aws ec2 authorize-security-group-ingress --group-name sec-application --cidr 0.0.0.0/0 --protocol tcp  --port 22  
aws ec2 authorize-security-group-ingress --group-name sec-application --source-group sec-balancer --protocol tcp  --port 5000  

### DB creation:  
aws rds create-db-instance --db-instance-identifier webappdb --allocated-storage 10 --db-instance-class db.t2.micro --engine mysql --master-username webapp --master-user-password hellowebapp12345  --vpc-security-group-ids <sg-id of sec-database>  
[note db host, user, pass, dbname]
[edit attributes/default.rb to include correct DB parameters]

### VM creation  
aws ec2 create-key-pair --key-name webappkey --output text > webappkey.pem  
[remove all text before ----BEGIN RSA PRIVATE KEY  and after END RSA PRIVATE KEY----- ]  
[chmod 600 webappkey.pem]  

aws ec2 run-instances --image-id ami-8e9ca3e4 --security-groups sec-application --instance-type t2.micro --key-name webappkey  
[note instance id]  

### ELB creation:  
aws elb create-load-balancer --load-balancer-name webappelb --listeners Protocol=http,LoadBalancerPort=80,InstanceProtocol=http,InstancePort=5000 --security-groups <sg-id of sec-balancer> --availability-zones us-east-1b  
[note dns name]  

"webappelb-1186309591.us-east-1.elb.amazonaws.com"  

aws elb register-instances-with-load-balancer --load-balancer-name webappelb --instances <instance id>  

----
aws ec2 describe-instances --instance-ids <instance id> | grep PublicIp
[note public-ip]

##Provision app on VM:  

ssh -i webappkey.pem admin@publicip  

sudo apt-get update  
sudo apt-get -y install git chef  
git clone --recursive https://github.com/sshmanko/cookbooks.git  
cd cookbooks  
sudo chef-client -z -o serverspec,webapp,serverspec::run_tests  
