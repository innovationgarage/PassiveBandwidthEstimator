FROM ubuntu:18.10

RUN apt update
RUN apt install -y nano mg
RUN apt install -y net-tools
RUN apt install -y iproute2
RUN apt install -y iperf
RUN apt install -y openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#* *PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN echo "export LC_ALL=en_US.UTF-8" >> /root/.bashrc

ADD server.sh /server.sh

CMD ["/server.sh"]
