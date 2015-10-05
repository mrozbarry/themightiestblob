
exec = require('child_process').exec
prompt = require('cli-prompt')

openSSLExecCallback = (error, stdout, stderr) ->
  if error
    console.error '[OPENSSL:Error]', error

  console.log '[OPENSSL:StdOut]', stdout
  console.log '[OPENSSL:StdErr]', stderr

openSSLGenerateCert = (keyPath, certPath) ->
  exec "openssl genrsa -out #{keyPath} 1024", (error, stdout, stderr) ->
    openSSLExecCallback(error, stdout, stderr)
    unless error
      exec "openssl req -new -key #{keyPath} -out #{certPath}", (error, stdout, stderr) ->
        openSSLExecCallback(error, stdout, stderr)
        unless error
          exec "openssl x509 -req -in #{certPath} -signkey #{keyPath} -out #{certPath}", (error, stdout, stderr) ->
            openSSLExecCallback(error, stdout, stderr)

createSelfSignedCertificate = ->
  basePath = 'config/securemq/server/cert'
  key = "#{basePath}/key.pem"
  cert = "#{basePath}/cert.pem"
  openSSLGenerateCert(key, cert)

console.log 'TheMightiestBlob Server Certificate Generator'
console.log '---------------------------------------------'
prompt.multi([
  label: '[I]nstall or [G]enerate an OpenSSL certificate'
  key: 'option'
  validate: (input) ->
    throw new Error('Please enter "I" or "G"') unless input.length == 1
], (result) ->
  switch(result.option.toLowerCase())
    when 'i' then console.log 'Copy key.pem and cert.pem into config/securemq/server/cert/'
    when 'g' then createSelfSignedCertificate()
)

