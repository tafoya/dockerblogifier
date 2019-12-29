# Grab the source then compile
# git clone https://github.com/blogifierdotnet/Blogifier.git
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app
#ARG appdir=Blogifier

# Copy everything else and build
#COPY $appdir/ ./
RUN git clone https://github.com/blogifierdotnet/Blogifier.git && mv ./Blogifier/* ./ && rm -rf ./Blogifier
RUN dotnet restore

RUN dotnet publish -c Release -o out

# Build runtime image
#FROM microsoft/dotnet:aspnetcore-runtime
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
RUN mkdir /conf && mkdir -p /template/wwwroot
ADD assets/start.sh /start.sh
WORKDIR /app

#copy all of the needed files
COPY --from=build-env /app/out/App.deps.json .
COPY --from=build-env /app/out/App.pdb .
COPY --from=build-env /app/out/App.runtimeconfig.json .
COPY --from=build-env /app/out/Core.pdb .
COPY --from=build-env /app/out/CoreAPI.xml .
COPY --from=build-env /app/out/Upgrade.deps.json .
COPY --from=build-env /app/out/Upgrade.runtimeconfig.json .
COPY --from=build-env /app/out/*.dll ./
# make needed folders and copy them over
RUN mkdir ./Pages \ 
    && mkdir ./refs \
    && mkdir ./Resources \
    && mkdir ./runtimes \
    && mkdir ./wwwroot

# Copy over needed folders
COPY --from=build-env /app/src/App/Pages ./Pages
COPY --from=build-env /app/out/refs ./refs
COPY --from=build-env /app/out/runtimes ./runtimes
COPY --from=build-env /app/out/Resources ./Resources
COPY --from=build-env /app/out/wwwroot ./wwwroot


# copy configurable files to template folder
COPY --from=build-env /app/out/appsettings.json /template/
COPY --from=build-env /app/out/app.db /template/
COPY --from=build-env /app/out/web.config /template/
COPY --from=build-env /app/out/wwwroot /template/wwwroot

# create symbolic links from the config folder
RUN ln -s /conf/appsettings.json /app/appsettings.json \
    && ln -s /conf/app.db /app/app.db \
    && ln -s /conf/web.config /app/web.config \
    && ln -s /conf/wwwroot /app/wwwroot

# copy files from template folder to config folder if they're not already there
RUN cp -r /template/* /conf/

# Add the script
ADD assets/start.sh /start.sh
RUN chmod 755 /*.sh

VOLUME /conf

#ENTRYPOINT ["dotnet", "App.dll"]
ENTRYPOINT ["/start.sh"]
