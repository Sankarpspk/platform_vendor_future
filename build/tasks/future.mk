FUTURE_TARGET_PACKAGE := $(PRODUCT_OUT)/Future-$(FUTURE_VERSION).zip

.PHONY: otapackage future bacon
otapackage: $(INTERNAL_OTA_PACKAGE_TARGET)
future: otapackage
	$(hide) mv $(INTERNAL_OTA_PACKAGE_TARGET) $(FUTURE_TARGET_PACKAGE)
	$(hide) $(MD5SUM) $(FUTURE_TARGET_PACKAGE) | cut -d ' ' -f1 > $(FUTURE_TARGET_PACKAGE).md5sum
	@echo -e ""
	@echo -e "${cya}Building ${bldcya}Future ${txtrst}";
	@echo -e ""
	@echo -e ${CL_GRN}"    8888888             8                                  "
	@echo -e ${CL_GRN}"   8         8     8   8888      8     8    8    8  88888  "
	@echo -e ${CL_GRN}"   8         8     8    8        8     8     8  8   8   8  "
	@echo -e ${CL_GRN}"   8888888   8     8    8        8     8      88    88888  "
	@echo -e ${CL_GRN}"   8         8     8    8        8     8    8   8   8      "
	@echo -e ${CL_GRN}"   8         8     8    8    8   8     8    8   8   8      "
	@echo -e ${CL_GRN}"   8          8 8 8     8 8 8     8 8 8      888    88888  "
	@echo -e ${CL_GRN}"   8                                                       "
	@echo -e ""
	@echo -e "zip: "$(FUTURE_TARGET_PACKAGE)
	@echo -e "md5: `cat $(FUTURE_TARGET_PACKAGE).md5sum | cut -d ' ' -f 1`"
	@echo -e "size:`ls -lah $(FUTURE_TARGET_PACKAGE) | cut -d ' ' -f 5`"
	@echo -e ""

bacon: future
