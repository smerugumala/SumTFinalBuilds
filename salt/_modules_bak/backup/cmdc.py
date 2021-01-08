import subprocess

def get():
    out = subprocess.run(['hostname', '-i'], stdout=subprocess.PIPE)
    return out.stdout
