# gem. Doku hier https://s3.amazonaws.com/foliodocs/api/mod-data-loader/loader.html

# MARCFILE=hbz01.w0001.wbb.sys.ok.z103.sys.first10.mrc
# MARCFILE=Atest.utf8.mrc
MARCFILE=2017-11-Business_Management_Economics_UTF8.mrc

# 2. Uploads a file with 1..n binary Marc records and returns those records as instance jsons. No data is saved to the database
curl -s -S -D - -H "X-Okapi-Tenant: diku" -H "Content-type: application/octet-stream" -H "Accept: text/plain" -d \@$MARCFILE http://localhost:8081/load/marc-data/test
exit 0
# 28 Mär 2019 12:39:31:566 INFO  Processor  inserted 7 in 0 seconds
# Kopiere das Ergebnis nach hbz01.w0001.wbb.sys.ok.z103.sys.first10.mrc.json
#
# Das sieht jetzt mal ganz gut aus:
# 04 Apr 2019 12:19:41:197 INFO  Processor  REQUEST ID 139a554e-586b-456a-8c0e-8afc2b915a7e
# 04 Apr 2019 12:19:41:228 INFO  Processor  inserted 6 in 0 seconds
# 04 Apr 2019 12:19:41:270 INFO  LogUtil  org.folio.rest.RestVerticle start  invoking public void org.folio.rest.impl.LoaderAPI.postLoadMarcDataTest(java.io.InputStream,java.util.Map,io.vertx.core.Handler,io.vertx.core.Context)
# 04 Apr 2019 12:19:41:292 INFO  LogUtil  0:0:0:0:0:0:0:1:40878 POST /load/marc-data/test null HTTP_1_1 201 4844 1098 tid=diku Created 
# 04 Apr 2019 12:19:41:292 INFO  Processor  Completed processing of REQUEST
# Kopiere das Ergebnis von Konsole nach 2017-11-Business_Management_Economics_UTF8.mrc.json

