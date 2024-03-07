#!/bin/bash

if [[ "$@" == "bash" ]]; then
    exec $@
fi

test -z "$BACKUP_DIR" && backup_dir='' || backup_dir=/${BACKUP_DIR}
test -z "$BACKUP_NAME" && backup_name='data' || backup_name=${BACKUP_NAME}
if [[ ! -z "$BACKUP_EXCLUDE" ]]; then
  if [[ $BACKUP_EXCLUDE =~ ^[a-zA-Z0-9,_.\*-]+$ ]]; then
    IFS=',' read -r -a dirs <<< "$BACKUP_EXCLUDE"
    exclude_params=()
    for dir in "${dirs[@]}"; do
      exclude_params+=("--exclude=$dir")
    done
    echo "Use tar options: "${exclude_params[@]}""
  else
    echo "BACKUP_EXCLUDE contains invalid characters, example 'ansible,.terraform,*.sql' without spaces"
    exit 1
  fi
else  
  exclude_params=("--exclude=")
fi

test -z "$LOCAL_PATH" && local_path=''|| local_path=${LOCAL_PATH}
test -z "$LOCAL_NAME_PREFIX" && local_name_prefix='' || local_name_prefix=${LOCAL_NAME_PREFIX}_

postfix=$(date +%Y-%m-%d).tar

backup_bin=$( [ "$BACKUP_FORMAT" = "xz" ] && echo "xz" || echo "gzip" )
backup_ext=$( [ "$BACKUP_FORMAT" = "xz" ] && echo ".xz" || echo ".gz" )

# Функция для получения фактических файлов срочной ротации
function get_files_to_delete() {
    local all_files=("$@")
    local -a to_delete=()

    # Сохраняем все даты бекапов для сравнения.
    local daily_cut_off_date=$(date -d "today - 6 days" +%Y-%m-%d)
    local -a weekly_cut_off_dates=()
    
    for (( i=1; i<=15; i++ )); do
        # Понедельники последних трех недель.
        local last_monday=$(date -d "last monday - $((i - 1)) weeks" +%Y-%m-%d)
        weekly_cut_off_dates+=("$last_monday")
    done
    
    for file in "${all_files[@]}"; do
        file_date_str=$(basename "$file" | egrep -o "\d{4}-\d{2}-\d{2}")
        if [[ "$file_date_str" > "$daily_cut_off_date" ]]; then
	        echo ${file}_pass
            continue
        fi

        for week_date in "${weekly_cut_off_dates[@]}"; do
            if [[ "$file_date_str" == "$week_date" ]]; then
		        echo ${file}_pass
                continue
            fi
        done
        to_delete+=("$file")
    done
    
    echo "${to_delete[@]}"
}

tar "${exclude_params[@]}" -cf /${backup_name}_${postfix} data${backup_dir}

$backup_bin /${backup_name}_${postfix}
mkdir -p /backup/${local_path}
cp /${backup_name}_${postfix}${backup_ext} /backup/${local_path}/${local_name_prefix}${backup_name}_${postfix}${backup_ext}

if [ $? -ne 0 ]; then
  exit 1
fi

if [[ ! -z "$ROTATION" ]]; then
  # Получение списка файлов в local storage и сортировка (новейшие файлы вверху).
  all_files=($(ls -l /backup/${local_path}/ | awk '{print $4}' | grep -- "${local_name_prefix}${backup_name}" | sort))
  # Определение файлов для удаления.
  files_to_delete=($(get_files_to_delete "${all_files[@]}" | grep -v _pass))

  # Вывод на удаление файлов.
  for file in "${files_to_delete[@]}"; do
      if [[ ! -z "$ROTATION_DRY_RUN" ]]; then
          echo "Will be deleted: $file"
      else
          echo "Deleting: $file"
          #rm -f "$file"
      fi
  done

  # Определение файлов для pass.
  files_to_pass=($(get_files_to_delete "${all_files[@]}" | grep _pass))

  # Вывод pass файлов.
  for file in "${files_to_pass[@]}"; do
      echo "Will be passed: $file" | sed 's/_pass//g'
  done
fi

exec "$@"
