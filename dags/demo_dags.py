from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'demo-dag',
    default_args=default_args,
    description='An example DAG with parallel tasks',
    # schedule_interval=timedelta(days=1), deprecated soon.
    schedule=timedelta(days=1),
)

# Task 1
task1 = BashOperator(
    task_id='task1',
    bash_command='echo "Task 1 completed"',
    dag=dag,
)

# Task 2
task2 = BashOperator(
    task_id='task2',
    bash_command='echo "Task 2 completed"',
    dag=dag,
)

# Task 3
task3 = BashOperator(
    task_id='task3',
    bash_command='echo "Task 3 completed"',
    dag=dag,
)

# Set task dependencies
task1 >> [task2, task3]