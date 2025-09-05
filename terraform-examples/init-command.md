```bash
export TERRAHARBOR_USER=goncalocheleno
export TERRAHARBOR_PASSWORD=qwerty123
export TF_PROJECT_NAME=test
export TF_STATE_NAME=default
terraform init -reconfigure \
    -backend-config="address=http://localhost/state/$TF_PROJECT_NAME/$TF_STATE_NAME" \
    -backend-config="lock_address=http://localhost/state/$TF_PROJECT_NAME/$TF_STATE_NAME" \
    -backend-config="unlock_address=http://localhost/state/$TF_PROJECT_NAME/$TF_STATE_NAME" \
    -backend-config="username=$TERRAHARBOR_USER" \
    -backend-config="password=$TERRAHARBOR_PASSWORD" \
    -backend-config="lock_method=LOCK" \
    -backend-config="unlock_method=UNLOCK" \
    -backend-config="retry_wait_min=5"
```
