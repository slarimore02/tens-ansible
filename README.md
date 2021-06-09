# Ansible for Traffic Emulator for Network Service (TENS)
Ansible Plays for installing and running tests with TE-NS Traffic Generator

https://github.com/vmware/te-ns

## Prerequisites
- Linux hosts created for TENS Controller and TEDPs (Traffic Generators). This can be one host or multiple depending on your needs and available compute resources.
- Docker installed on TENS Controller and TEDP hosts
- Ansible 2.10 or above installed on the the host that will run the Ansible playbooks for TENS
- The community.docker collection installed with ```ansible-galaxy collection install community.docker```

## Setup Instructions
1. Clone Repo and change to cloned directory
```bash
git clone https://github.com/slarimore02/tens-ansible.git
cd tens-ansible
```
2. Edit hosts file
- The IP Address of the TENS Controller should be added to the [te] group
- The IP Address(es) of the TEDPs should be added to the [tedp] group
3. Edit global_vars.yml file
- The IP address of the TENS Controller and API port (default 5000) should be added to the respective controller_ip and controller_port variables


## TENS Controller Setup
1. Edit variables in the 1_setup-te-controller.yml as required. The defaults are listed below and should work for most use cases.
```
vars:
    grafana_port: "5002"
    redis_port: "6378"
    postgres_port: "5432"
    zmq_port: "5555"
```
2. Run Ansible Play with the ssh user defined (ubuntu given as example)
```bash
ansible-playbook -u ubuntu -i hosts 1_setup-te-controller.yml
```

## TEDP Host Setup
1. Edit variables in the 2_setup-tedp.yml as required. The dataplane interface and username/password credentials for the hosts should be changed to reflect your environment. Alternatively the credentials can sent via the -e option to the ansible-playbook command.
```
vars:
    tedp_version: "v2.0"
    dp_interface: "ens192"
    username: "ubuntu"
    password: "ubuntu"
```
2. Run Ansible Play with the ssh user defined (ubuntu given as example)
```bash
ansible-playbook -u ubuntu -e username=ubuntu -e password=password -i hosts 2_setup-tedp.yml
```

## Generate JSON Test Files for TENS
1. Edit variables in the 3_generate-https-tests.yml or 3_generate-udp-tests.yml files depending on what type of test you'd like to run. These variables will be used to generate a JSON file used by TENS.

2. Run Ansible Play to generate test files. Generated files will be in the files directory.
```bash
ansible-playbook 3_generate-https-tests.yml
ansible-playbook 3_generate-udp-tests.yml
```
3. The generated test files can be tweaked as needed based on the following documents:

https://github.com/vmware/te-ns/blob/main/RESOURCE_CONFIGURATION.md

https://github.com/vmware/te-ns/blob/main/SESSION_CONFIGURATION.md

## Start Traffic Test
1. Edit the test type in the 4_start-test.yml file as needed. The available tests are https_rps or udp_rps. 
```
vars:
    test_type: https_rps
```
2. Run Ansible Play to start traffic test
```bash
ansible-playbook 4_start-test.yml
```
## Stop Traffic Test
```bash
ansible-playbook 5_stop-test.yml
```
