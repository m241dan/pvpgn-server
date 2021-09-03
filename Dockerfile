#
# BUILD
#
FROM ubuntu:20.04 as build

# BUILD ARGS
ARG with_mysql=false
ARG with_sqlite3=false
ARG with_pgsql=false
ARG with_odbc=false
ARG with_lua=false

# APT UPDATES
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    cmake \
    build-essential \
    zlib1g-dev \
    liblua5.1-0-dev \
    $(if ${with_mysql}; then echo "libmysqlclient-dev libmysqlclient21"; fi) \
    $(if ${with_sqlite3}; then echo "libsqlite3-dev libsqlite3-0"; fi) \
    $(if ${with_pgsql}; then echo "libpq-dev libpq5"; fi) \
    $(if ${with_odbc}; then echo "unixodbc-dev libodbc1"; fi) \
    && rm -rf /var/lib/apt/lists/*

# BRING IN CODE
COPY . ./pvpgn-server

WORKDIR /pvpgn-server

# BUILD CODE
RUN cmake -H./ -B./build \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=/usr/local/pvpgn \
    -DWITH_LUA=${with_lua} \
    -DWITH_MYSQL=${with_mysql} \
    -DWITH_SQLITE3=${with_sqlite3} \
    -DWITH_PGSQL=${with_pgsql} \
    -DWITH_ODBC=${with_odbc}

WORKDIR /pvpgn-server/build

RUN make -j$(nproc)

# INSTALL CODE
RUN make install

#
# PRODUCTION
#
FROM ubuntu:20.04 as production

COPY --from=build /usr/local/pvpgn /usr/local/pvpgn

WORKDIR /usr/local/pvpgn/sbin
