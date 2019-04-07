BMv2_DIR=/home/netarchlab/behavioral-model/targets/simple_switch
MAIN_FILE=hyperv.p4
COMMIT_REASON=?"defaut commit"
LOG="--log-console"
INTF1="-i 1@p4p1" 
INTF2="-i 2@p4p2"


compile:
	@mkdir -p build
	@p4c-bmv2 src/${MAIN_FILE} --json build/hyperv.json

clean:
	@rm -rf build

git:
	@git add -A
	@git commit -a -m $COMMIT_REASON
	@git push -u origin master

run: 
	@cp build/hyperv.json $(BMv2_DIR)
	@cd $(BMv2_DIR)&&sudo bash simple_switch hyperv.json $(INTF1) $(INTF2) $(LOG)
