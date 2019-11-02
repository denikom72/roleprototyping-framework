# roleprototyping-framework
Perl-Fullstack-Framework for rapid prototpying of role- and session-based webapplication 

Install the apache2-extension, perlmod, then it have to be activated ( use the cli-command "a2enmod" ).

Open the file "/etc/hosts".
Extend to sentence "127.0.0.1 localhost" into "127.0.0.1 localhost roleproto-frame".

Create the file "roleproto-frame.conf" in the directory "/etc/apache2/sites-available".

Write following directives into the new conf-file


        <VirtualHost *:80>

        ServerName roleproto-frame
        DocumentRoot "/var/www/roleproto-frame"
        ErrorLog /var/log/apache2/error.log
        CustomLog /var/log/apache2/access.log agent
        LogLevel debug
        RewriteEngine on
        <Directory /var/www/roleproto-frame>
                AddHandler perl-script .pl
                PerlResponseHandler ModPerl::Registry
                Options +ExecCGI
                PerlOptions +ParseHeaders
                AllowOverride All
                Order allow,deny
                Allow from all
        </Directory>
        
        </VirtualHost>


Close the conf-file and run the cli-command "service apache2 restart <<ENTER>>"
  
Now you should use the DB_DUMP.sql for creating the database and create a superuser for the application by following command:

.......



