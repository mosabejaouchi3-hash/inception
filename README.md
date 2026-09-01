Why does the project require the use of the Penultimate Stable release of Debian (Bullseye), and what is the difference between it and Bookworm?

لتجنب المشاكل  التقنية التي تكون في الإصدارات الجديد و الثغرات
النسخ المستقرة تكون أفضل في التعلم لأنها لا يكون فيها الكثير من الشاكل

----------------------------------------------------------------------------------------

What is the fundamental difference between the `debian:bullseye` image and the `debian:bullseye-slim` image?

هناك فرق من ناحية الحجم 
debian:bullseye > debian:bullseye-slim

----------------------------------------------------------------------------------------

How does the “restart: always” option ensure service continuity in a production environment?

يعيد تشغيل تلك السيرفيس التي فيها وضع “restart: always”
عند حدوث مشكل داخلها أو اي خروج كيف ما كان كان by exit 0 to other

----------------------------------------------------------------------------------------

What is the role of networks such as n-inception, and why do we use a user-defined bridge network instead of a virtual network?

لكي تكون جميع serveses in one network for ونستخدم bridge لكي يكون فصل بين network host and network containers

----------------------------------------------------------------------------------------

How does Internal DNS work within a Docker network to allow WordPress to connect to MariaDB using only the name?

يكون مثل table يبحث فيه عن Ip مخصص لكل container ب name of container 

----------------------------------------------------------------------------------------

What is the purpose of the .dockerignore file, and why did we exclude the .git folder and the .env and secrets/ files from it?

عند عمل docker push لا يتم push folder and files التي في .dockerignore 
لمادا قمنا بوضع داخلهم 
.git && .env && secrets
لأن فيه بيانات حساس في secrets
و .git فيها أسماء ملفات الحساس 
env لا أعرف

----------------------------------------------------------------------------------------

What is the difference between the CMD command and the ENTRYPOINT command in a Dockerfile?

كليهما أعرف أنه يعملان عند عمل container 

----------------------------------------------------------------------------------------

What is the difference between passing passwords via environment variables and passing them via Docker Secrets?

إدا مررتها عبر env يمكن لأي شخص عبر inspect رأيت كل env الخاص ب دالك container أو عن طريق أمر env في داخل container 
أما  docker secret لا يمكننك رأيتها ب inspect ولا ب env لاكن يمكنك رايتها إن عمل قرأة ملف التي كتبة فيه وسط container 

----------------------------------------------------------------------------------------

Where does Docker store secrets in the container's file system during runtime?

في tmpfs

----------------------------------------------------------------------------------------

What is the difference between regular storage spaces (Docker Named Volumes) and Bind Mounts linked to /home/mjaouchi/data?

الفرق واحد تدار من docker engine وأخرى تدار منك أنت بشكل كامل 
Name volume : docker engine 
Mount Bind : from you

----------------------------------------------------------------------------------------

What happens to the database data and WordPress posts if I delete the containers using `docker compose down` and then rebuild them?

إدا كنت تستعمل Named Volume تحدف بكامل 
أما إن كنت تستخد Mount Bind فتبقى

----------------------------------------------------------------------------------------

How do you manage user permissions (chown / chmod) between the host operating system and the www-data account within containers?

I dont know

----------------------------------------------------------------------------------------

Why is NGINX the only container in the core architecture that opens an external port (443:443)?

for security because nginx is server connect with client

----------------------------------------------------------------------------------------

What is a self-signed SSL certificate, and what does the command `openssl req -x509` do?

هي التي تأد بها للمستخدم أنك جهة موثوقة هي جزء من عملية create sesion key

----------------------------------------------------------------------------------------

3. خادم NGINX وتشفير TLS/SSL


كل أسئلة هاد القسم تقريبا لا يمكنني الإجابة عنها لأني لا أفهمها جيدا

----------------------------------------------------------------------------------------

What is the difference between php-fpm and php-cli, and why did we install them both inside the container?

php-fpm 
هو fastCGI-process-managent 
هو الدي يقوم بمعالجة file.php ويعيد النتيجة عبر protocol fastCGI

أما php-cli هو أوامر التي نستخدمها لإستعمال php-fpm

----------------------------------------------------------------------------------------

Why do we change the listening port at www.conf from the default Unix socket to port 0.0.0.0:9000?

لكي تتمكن من التواصل عبر protocol TCP/IP
و تواصل عبر IPs ب Port 9000

----------------------------------------------------------------------------------------

What is the WP-CLI tool, and what are the architectural benefits of using it to automate website installation instead of the graphical interface?


هي التي تقوم ب إعداد ملفات wordpress بشكل ألي 
مثل Init database
and create User of Admine and any user
فقط عبر cmd line

----------------------------------------------------------------------------------------

Why does the WordPress setup script require the mariadb-client package?

ليستطيع التواصل مع mariadb server و وصل wordpress by maraidbs-server

----------------------------------------------------------------------------------------

Why did we check for the existence of a file like version.php before copying the WordPress files to /var/www/html within the script?

......

----------------------------------------------------------------------------------------

How can you prevent a race condition between WordPress startup and MariaDB server readiness?

لأن Wordpress لكي تنطلق يجب أن تكون mariadb جاهزة

----------------------------------------------------------------------------------------

Why should PHP-FPM be run on the last line of the script using `exec php-fpm7.4 -F` (in foreground mode)?

لكي يستقبل أي request تأتيه من عند nginx 

----------------------------------------------------------------------------------------

What is the difference between the mariadb-server package and the mariadb-client package?

mariadb-server : هي التي تدير البيانات و table و تخزن البيانات 
أما mariadb-client: هي client الدي يستخدم maraidb ليخزن فيها البيانات و يتحكم فيها و ينشأ ويحدف
و يعدل

----------------------------------------------------------------------------------------

