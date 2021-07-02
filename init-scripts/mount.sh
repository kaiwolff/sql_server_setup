#sudo mkfs -t xfs /dev/xvdz
sudo mkdir /data
sudo mount /dev/xvdz /data
sudo chown ec2-user -R /data
