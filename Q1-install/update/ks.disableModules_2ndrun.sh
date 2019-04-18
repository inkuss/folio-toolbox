#!/bin/bash
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-audit-0.0.3
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-authtoken-2.0.4
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-circulation-14.1.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-circulation-storage-6.2.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-configuration-5.0.1
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-email-1.0.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-erm-usage-1.0.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-feesfines-15.1.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-finance-storage-1.0.1
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-inventory-11.0.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-inventory-storage-14.0.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-login-4.6.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-notify-2.1.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-password-validator-1.0.1
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-permissions-5.4.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-users-15.3.0
curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-vendors-1.0.3

