#
# Docker
#
# Docker automates the repetitive tasks of setting up development environments
# Link: https://www.docker.com

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_DOCKER_SHOW="${SPACESHIP_DOCKER_SHOW=true}"
SPACESHIP_DOCKER_PREFIX="${SPACESHIP_DOCKER_PREFIX="on "}"
SPACESHIP_DOCKER_SUFFIX="${SPACESHIP_DOCKER_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_DOCKER_SYMBOL="${SPACESHIP_DOCKER_SYMBOL="🐳 "}"
SPACESHIP_DOCKER_COLOR="${SPACESHIP_DOCKER_COLOR="cyan"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current Docker version and connected machine
spaceship_docker() {
  [[ $SPACESHIP_DOCKER_SHOW == false ]] && return

  spaceship::exists docker || return

  # Better support for docker environment vars: https://docs.docker.com/compose/reference/envvars/
  # Use COMPOSE_PATH_SEPARATOR or colon as default
  local separator=":"
  [[ ! -z $COMPOSE_PATH_SEPARATOR ]] && separator=$COMPOSE_PATH_SEPARATOR

  # COMPOSE_FILE may have several filenames separated by colon, test all of them
  local filenames=("${(@ps/$separator/)COMPOSE_FILE}")

  local compose_exists
  for filename in $filenames; do
    if [[ ! -f $filename ]]; then
      compose_exists=false
      break
    fi
    compose_exists=true
  done

  # Show Docker status only for Docker-specific folders
  [[ "$compose_exists" == true || -f Dockerfile || -f docker-compose.yml ]] || return

  # if docker daemon isn't running you'll get an error saying it can't connect
  local docker_version=$(docker version -f "{{.Server.Version}}" 2>/dev/null)
  [[ -z $docker_version ]] && return

  if [[ -n $DOCKER_MACHINE_NAME ]]; then
    docker_version+=" via ($DOCKER_MACHINE_NAME)"
  fi

  spaceship::section \
    "$SPACESHIP_DOCKER_COLOR" \
    "$SPACESHIP_DOCKER_PREFIX" \
    "${SPACESHIP_DOCKER_SYMBOL}v${docker_version}" \
    "$SPACESHIP_DOCKER_SUFFIX"
}
