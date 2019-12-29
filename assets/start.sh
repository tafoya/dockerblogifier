#! /bin/sh

if [ ! -f /conf/app.db ]; then
	cp /template/app.db /conf/app.db
fi

if [ ! -f /conf/web.config ]; then
        cp /template/web.config /conf/web.config
fi

if [ ! -f /conf/appsettings.json ]; then
        cp /template/appsettings.json /conf/appsettings.json
fi

if [ ! -f /conf/wwwroot/ ]; then
        cp -r /template/wwwroot /conf/
fi

dotnet App.dll
