from util.generatepresharedkey import generate_key
import os

__location__ = os.path.realpath(
    os.path.join(os.getcwd(), os.path.dirname(__file__)))

clair_key, clair_key_id = generate_key('security_scanner','security_scanner Service Key',
									notes='Preshared Key for clair')

print 'security_scanner.pem:' + clair_key_id
claircert = open(os.path.join(__location__,'security_scanner.pem'), 'w')
claircert.write(clair_key.exportKey())
claircert.close()