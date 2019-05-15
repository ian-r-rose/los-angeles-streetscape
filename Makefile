.PHONY: osm check-postgres

OSM_SOUTHERN_CALIFORNIA = https://download.geofabrik.de/north-america/us/california/socal-latest.osm.pbf
OSM_PBF = socal.osm.pbf
POSTGRES_VARIABLES = POSTGRES_USER POSTGRES_DB POSTGRES_PASSWORD POSTGRES_PORT POSTGRES_HOST
POSTGRES_GUARDS = $(patsubst %, guard-%, $(POSTGRES_VARIABLES))


# Allow rules to verify that variables are defined.
guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi


# Check for a valid set of postgres variables
check-postgres: $(POSTGRES_GUARDS)


# Download the OSM PBF
$(OSM_PBF):
	wget -O $@ ${OSM_SOUTHERN_CALIFORNIA}


# Copy the OSM data into the database.
osm: $(OSM_PBF) check-postgres
	ogr2ogr -f PostgreSQL \
					PG:"dbname='${POSTGRES_DB}' user='${POSTGRES_USER}' password='${POSTGRES_PASSWORD}' port='${POSTGRES_PORT}' host='${POSTGRES_HOST}'"\
					-lco SCHEMA=osm -lco OVERWRITE=yes --config PG_USE_COPY YES $(OSM_PBF)
