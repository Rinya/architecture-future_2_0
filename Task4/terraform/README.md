# Запуск Terraform скриптов

## 1. Перед запуском выполнить подстановку переменных среды
### Linux/Mac
export TF_VAR_yc_token="<ваш_токен>"
export TF_VAR_yc_cloud_id="<ваш_cloud_id>"
export TF_VAR_yc_folder_id="<ваш_folder_id>"

### Windows (PowerShell)
$env:TF_VAR_yc_token="<ваш_токен>"
$env:TF_VAR_yc_cloud_id="<ваш_cloud_id>"
$env:TF_VAR_yc_folder_id="<ваш_folder_id>"

### Windows (CMD)
set TF_VAR_yc_token=<ваш_токен>
set TF_VAR_yc_cloud_id=<ваш_cloud_id>
set TF_VAR_yc_folder_id=<ваш_folder_id>

## 2. Подготовка переменных
Переименовать файл terraform.tfvars.example в terraform.tfvars
```
mv terraform.tfvars.example terraform.tfvars
```

## 2. Выполнить terraform init
```
terraform init
```

# 3. Проверить план
```
terraform plan -out=tfplan
```

# 4. Применить
```
terraform apply tfplan
```

# 5. Удалить (когда нужно)
```
terraform destroy
```

# 6. Очистка
```
rm -rf .terraform* terraform.tfstate* tfplan
```