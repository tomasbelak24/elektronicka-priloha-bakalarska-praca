import subprocess
import time
from datetime import datetime

# Treba napisat do konzole
# conda create --name bak python=3.12.0 
# conda activate bak 
# pip install -r requirements.txt 
# python -m ipykernel install --user --name bak --display-name "Python Kernel Bakalarka"
# Az potom spustit workflow.py

def run_notebook(notebook_path, kernel_name):

    """
    Funkcia spustí Jupyter notebook a odmeria dĺžku behu programu.

    Argumenty:
    notebook_path (str): Cesta k Jupyter notebooku, ktorý sa má spustiť.
    kernel_name (str): Názov Python kernelu, ktoré sa má použiť na spustenie notebooku.

    Návratová hodnota:
    tuple: Dvojica (elapsed_time, status), kde elapsed_time je čas v sekundách,
           ktorý trvalo spustenie notebooku, a status je reťazec, ktorý indikuje
           úspech ('success') alebo zlyhanie ('failure') spustenia notebooku.

    Príklad:
    >>> run_notebook("path/to/notebook.ipynb", "python3")
    (12.34, 'success')
    """
    
    cmd = [
        "jupyter", "nbconvert", "--to", "notebook", "--execute",
        "--inplace", notebook_path, "--ExecutePreprocessor.kernel_name=" + kernel_name
    ]
    
    start_time = time.time()
    try:
        print(f'Spúšťam {notebook_path}')
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        elapsed_time = time.time() - start_time
        print(f"Úspešne zbehlo {notebook_path} za {elapsed_time:.2f} sekúnd")
        return elapsed_time, "success"
    except subprocess.CalledProcessError as e:
        elapsed_time = time.time() - start_time
        print(f"Error pri priebehu {notebook_path}: {e.stderr} , za {elapsed_time:.2f} sekúnd")
        return elapsed_time, "failure"
    
if __name__ == "__main__":
    
    notebooks = [
        "1_preprocessing.ipynb",
        "2_poloha.ipynb",
        "3_preklad.ipynb",
        "4_nacitaj_do_db.ipynb"
    ]

    path = r"./workflow-notebooks/"
    kernel = 'bak'
    log_data = []
    total_start_time = time.time()
    
    # Postupne spustanie jupyter notebookov
    for i, notebook in enumerate(notebooks, start=1):
        print(f'Task {i}/{len(notebooks)}')
        elapsed_time, result = run_notebook(path + notebook, kernel)
        log_data.append((notebook, elapsed_time, result))
        if result == 'failure':
            break
    
    total_elapsed_time = time.time() - total_start_time

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = f'./logs/log_{timestamp}.txt'
    
    # Logovanie spustenia
    with open(log_file, mode='a') as file:
        date_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        file.write(f"date: {date_str}\n")
        file.write(f"total: {total_elapsed_time:.2f} s\n")
        for notebook, elapsed_time, result in log_data:
            file.write(f"{notebook}: {elapsed_time:.2f} s, result: {result}\n")
    print(f'Ukončené za {total_elapsed_time} sekúnd')