FROM aifrak/elixir:1.11.3-23.2.7-erlang-buster-slim as build-elixir

# oh-my-zsh + nerd font + fira code + LSD Deluxe
FROM aifrak/oh-my-zsh:0.3.2 AS oh-my-zsh
FROM build-elixir AS build-dev

ARG APP_USER_ZSH=$APP_USER_HOME/.oh-my-zsh
ARG APP_USER_ZSH_CUSTOM=$APP_USER_ZSH/custom

# zsh
COPY --from=oh-my-zsh /bin/rzsh /bin/zsh /bin/zsh5 /bin/
COPY --from=oh-my-zsh /usr/bin/zsh /usr/bin/zsh
COPY --from=oh-my-zsh \
  /usr/lib/x86_64-linux-gnu/zsh /usr/lib/x86_64-linux-gnu/zsh
COPY --from=oh-my-zsh /usr/share/zsh /usr/share/zsh

# oh-my-zsh
ARG ZSH_USER_HOME=/home/zsh-user
ARG ZSH_USER_ZSH=$ZSH_USER_HOME/.oh-my-zsh

COPY --from=oh-my-zsh --chown=$APP_USER:$APP_USER_GROUP \
  $ZSH_USER_ZSH $APP_USER_ZSH

COPY --from=oh-my-zsh --chown=$APP_USER:$APP_USER_GROUP \
  $ZSH_USER_HOME/.zshrc $ZSH_USER_HOME/.p10k.zsh $APP_USER_HOME/

COPY --from=oh-my-zsh --chown=$APP_USER:$APP_USER_GROUP \
  $ZSH_USER_ZSH/custom/aliases.zsh $APP_USER_ZSH

# LSD Deluxe
COPY --from=oh-my-zsh /usr/bin/lsd /usr/bin/lsd

# FZF - executable only (required for zsh-interactive-cd)
COPY --from=oh-my-zsh /usr/local/bin/fzf /usr/local/bin/fzf

# Nerd Fonts
COPY --from=oh-my-zsh --chown=$APP_USER:$APP_USER_GROUP \
  /usr/local/share/fonts /usr/local/share/fonts

# Keep history in iex
RUN echo "alias iex='iex --erl \"-kernel shell_history enabled\"'" \
  >> "$APP_USER_ZSH_CUSTOM/aliases.zsh"

CMD ["zsh"]
