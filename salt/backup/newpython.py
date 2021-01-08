import subprocess
def get():
    out = subprocess.check_output('hostname -i', shell=True).rstrip('\n')
    return out