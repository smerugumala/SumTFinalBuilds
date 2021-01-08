import subprocess
import salt.modules.smtp

def email_errors(fromaddr, toaddrs, subject, data_str, smtp_server):
   data = eval(data_str)
   error = False
   changes = False

   if type(data['return']) is dict:
      for state, result in data['return'].iteritems():
         if not result['result']:
            error = True
            break
         if result['changes']:
            changes = True
            break
   else:
      if not data['success']:
         error = True

   if error or changes:
      body = subprocess.check_output(["salt-run", "jobs.lookup_jid", data['jid']])
      salt.modules.smtp.send_msg(\
            toaddrs,\
            body,\
            subject=subject,\
            sender=fromaddr,\
            server=smtp_server,\
            use_ssl=True)

   return True
