# seng533-project

## Notes:

- All steps were done in WSL Ubuntu terminal
- Docker Desktop must be installed prior

## Step 1: Set up Docker

- Create docker network and volume
  - `docker network create mongo_net`
  - `docker volume create mongo_data`

- Run MongoDB with fixed network port and persistent storage
  - `docker run -d --name mongo --network mongo_net -p 27017:27017 -v mongo_data:/data/db mongo:7`

- Check to see if it is running
  - `docker ps`
  - Should see: `mongo` and `27017->27017`

- Connect with shell and check if working properly
  - `docker exec -it mongo mongosh`
  - In shell:
    - `db.runCommand({ ping: 1 })`
    - Should see response:
      - `{ ok: 1 }`

## Step 2: Install and Build Test Tool YCSB

- Update packages and install maven
  - `sudo apt update`
  - `sudo apt install -y git maven openjdk-17-jdk`
  - Note: Apache Maven 3.6.3 was used
    - To downgrade version:
      - `sudo apt remove maven`
      - `cd /tmp`
      - `wget https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz`
      - `sudo tar -xzf apache-maven-3.6.3-bin.tar.gz -C /opt`
      - `nano ~/.bashrc`
      - Add the following lines:
        - `export MAVEN_HOME=/opt/apache-maven-3.6.3`
        - `export PATH=$MAVEN_HOME/bin:$PATH`
      - `source ~/.bashrc`
      - Confirm version: `mvn -v`

- Clone and build YCSB
  - `cd ~`
  - `git clone https://github.com/brianfrankcooper/YCSB.git`
  - `cd YCSB`
  - `mvn -pl site.ycsb:mongodb-binding -am clean package -DskipTests`
  - Note: If pushing changes, do not push up the YCSB directory

## Step 3: Run experiment

- Custom workload files to change workload ratios can be found in `experimentFiles/workloads`
- Record system details: - Navigate to root directory of repo and call: `docker exec -it mongo mongostat 1 | tee system/mongostat_live.txt` - Results will be stored in `system` directory
- Run experimental loop:
  - Navigate to `experimentFiles/scripts`
  - Call: `./run_experiments.sh`
  - Individual trial results will be stored in `results/raw`
