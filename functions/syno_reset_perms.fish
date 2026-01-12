function syno_reset_perms --description "Сброс ACL. -m (маска), -M (маска 022), -p (права)"
    # Парсинг аргументов:
    # R - рекурсивно
    # m - маска (умный режим)
    # M - быстрая маска 022
    # p - прямые права (chmod)
    argparse 'R/recursive' 'm/mask=' 'M/default' 'p/perms=' -- $argv
    or return

    if test (count $argv) -lt 1
        set_color red
        echo "❌ Ошибка: Укажите путь."
        echo "   Синтаксис: syno_reset_perms [-R] [опции] <путь>"
        echo "   -M      : Стандарт (Маска 022 -> Папки 755, Файлы 644)"
        echo "   -m 002  : Своя маска (002 -> Папки 775, Файлы 664)"
        echo "   -p 777  : Жесткие права (одинаковые для папок и файлов)"
        set_color normal
        return 1
    end

    set -l target $argv[1]

    if not test -e $target
        set_color red; echo "❌ Путь '$target' не найден."; set_color normal
        return 1
    end

    # === 1. СБРОС ACL И ВЛАДЕЛЬЦА (Всегда) ===
    
    set_color yellow
    if set -q _flag_R
        echo "🔄 [Рекурсивно] Чистим ACL и меняем владельца..."
        sudo find "$target" -exec synoacltool -del {} \; > /dev/null 2>&1
        sudo chown -R $USER:users "$target"
    else
        echo "📄 [Одиночно] Чистим ACL и меняем владельца..."
        sudo synoacltool -del "$target" > /dev/null 2>&1
        sudo chown $USER:users "$target"
    end
    set_color normal

    # === 2. ВЫЧИСЛЕНИЕ ПРАВ ===

    set -l dir_mode ""
    set -l file_mode ""

    # Сценарий 1: Прямые права (-p)
    if set -q _flag_p
        set dir_mode $_flag_p
        set file_mode $_flag_p
        echo "🛡️ [Mode: Direct] Устанавливаем '$dir_mode' на всё."

    # Сценарий 2: Маска (-m или -M)
    else if set -q _flag_m; or set -q _flag_M
        set -l umask_val ""
        
        if set -q _flag_M
            set umask_val "022"
        else
            set umask_val $_flag_m
        end

        # Вычисляем права через Python (777 & ~mask), так как в shell с битами сложно
        # Папки = 777 - mask
        # Файлы = 666 - mask
        set dir_mode (python3 -c "print(oct(0o777 & ~0o$umask_val)[2:])")
        set file_mode (python3 -c "print(oct(0o666 & ~0o$umask_val)[2:])")

        echo "🛡️ [Mode: Mask $umask_val] Папки -> $dir_mode, Файлы -> $file_mode"

    else
        echo "ℹ️ [Info] Права (chmod) не меняются (флаги не переданы)."
        set_color green; echo "✅ Готово."; set_color normal
        return 0
    end

    # === 3. ПРИМЕНЕНИЕ ПРАВ ===

    if set -q _flag_R
        # Рекурсивно
        if test "$dir_mode" = "$file_mode"
            # Если права одинаковые (флаг -p), делаем быстро
            sudo chmod -R "$dir_mode" "$target"
        else
            # Если разные (маска), ищем папки и файлы отдельно
            sudo find "$target" -type d -exec chmod "$dir_mode" {} \;
            sudo find "$target" -type f -exec chmod "$file_mode" {} \;
        end
    else
        # Одиночно
        if test -d "$target"
            sudo chmod "$dir_mode" "$target"
        else
            sudo chmod "$file_mode" "$target"
        end
    end

    set_color green; echo "✅ Готово."; set_color normal
end
