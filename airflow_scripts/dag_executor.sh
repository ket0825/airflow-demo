#!/bin/bash

# At project root directory.
# ex) ./airflow_scripts/dag_executor.sh --dag_path=path/to/the/dag.py
echo "Current working directory: $(pwd)" 
echo "HOSTNAME: $(hostname)" 
echo "Python executor: $(which python)"

while [[ $# -gt 0 ]]; do  # $인수 # number가 -gt greater than 0 이면, # [[]]는 조건문 나타내는 이중대괄호.
  case $1 in # case 값 in
    --dag_path=*) # 패턴1)
      echo $#
      dag_path=$(echo $1 | cut -d'=' -f2) # 명령1
      shift # 명령2      
      ;; # ;;
    *) # *)
      echo $#
      echo "Invalid option: $1" >&2 # 기본 명령, &2는 파일 디스크립터2 (stderr)
      exit 1
      ;;
  esac # esac escape case.
done

if [ -z "$dag_path" ]; then
  echo "Please provide the --dag_path argument." >&2
  exit 1
fi

if [ ! -f "$dag_path" ]; then # 지정된 path에 파일이 존재하는지 확인.
  echo "The specified DAG file does not exist: $dag_path" >&2
  exit 1
fi

# DAG 파일 실행 테스트.
python "$dag_path" >/dev/null 2>&1 # /dev/null로 출력 미표시, 2 (stderr)를 >&1 (stdout)으로 리다이렉션하여 오류 미표시.

if [ $? -ne 0 ]; then # 전에 명령이 not equal 0이면
  echo "Invalid DAG file: $dag_path" >&2 
  exit 1
fi

airflow_home=${AIRFLOW_HOME:-$HOME/airflow} # AIRFLOW_HOME 있으면 OK, 아니면 디폴트로 $HOME/airflow임.
airflow_dags_folder="$airflow_home/dags"

if [ ! -d "$airflow_dags_folder" ]; then # 디렉토리 존재 확인.
    cd $AIRFLOW_HOME
    mkdir dags
    echo "DAG directory created."
fi

dag_file=$(basename "$dag_path")
target_dag_path="$airflow_dags_folder/$dag_file"

if [ -f "$target_dag_path" ]; then
  echo "WARNING: The DAG file already exists in the Airflow DAGs folder: $target_dag_path" >&2
  echo "Skipping DAG execution."
  exit 0
fi

cp "$dag_path" "$target_dag_path" 

if [ $? -eq 0 ]; then # 이전 명령의 종료 상태 코드를 확인합니다. 종료 상태 코드가 0이면 (성공적으로 복사되었으면) 
  echo "DAG file copied successfully: $target_dag_path"
  python "$target_dag_path"
else
  echo "Failed to copy DAG file: $dag_path" >&2
  exit 1
fi



