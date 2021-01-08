Set Sudoers:
  file.append:
    - name: /etc/sudoers
    - text: |
        %domain\ admins ALL=(ALL)       ALL
        svc_saltstack ALL=(ALL) NOPASSWD: ALL