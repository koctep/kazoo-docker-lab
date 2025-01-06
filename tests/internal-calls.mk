test: CPS = 15
test: MAX_CALLS = 10
test: TOTAL_CALLS = 100
test: start wait-for-regs force
	$(MAKE) connect/fs-devices RUN="originate.sh $(TOTAL_CALLS) $(MAX_CALLS) $(CPS) '$(ORIGINATE_CMD)'"
	sleep 5
	$(MAKE) connect/fs-devices RUN="fs_cli -x 'hupall'"
	sleep 5
	$(MAKE) connect/kz RUN='curl http://amqp.kz:15692/metrics 2> /dev/null | grep rabbitmq_channel_messages_delivered_total'
