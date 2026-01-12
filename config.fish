# 1. Глобальные настройки (применяются ВСЕГДА)
# Это гарантирует, что scp/ssh-команды будут создавать файлы с правами 644/755
umask 022

# 2. Интерактивные настройки (только когда ты сам за клавиатурой)
if status is-interactive
    # Исправление терминала
    if test "$TERM" = "xterm-256color"
        set -gx TERM xterm
    end

    # Настройка путей
	fish_add_path $HOME/go/bin            # Go
    fish_add_path $HOME/.npm-global/bin   # NPM
    fish_add_path "$HOME/.local/bin"      # UV / Local бинарники 
    fish_add_path "$HOME/.cargo/bin"      # Rust / Cargo
    
    # Тут можно добавить алиасы, приветствие, Starship и т.д.
end
