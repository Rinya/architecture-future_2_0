## Диаграмма автоматизации развёртывания
```plantuml
@startuml
!define RECTANGLE class

skinparam componentStyle rectangle
skinparam backgroundColor #F9F9F9
skinparam ArrowColor #333333
skinparam defaultFontSize 14
skinparam noteBackgroundColor #FFFFFF
skinparam noteBorderColor #CCCCCC

title Диаграмма автоматизации развертывания\nКомпания "Будущее 2.0"

package "Инструменты управления инфраструктурой" {
  component "Terraform\nEnterprise/Cloud" as TERRAFORM #LightBlue
  component "GitHub/GitLab\n(Репозиторий кода)" as GIT #LightBlue
  component "Azure DevOps/TeamCity\n(CI/CD)" as CICD #LightBlue
  component "HashiCorp Vault\n(Управление секретами)" as VAULT #LightBlue
}

package "Компоненты, управляемые Terraform (IaC)" #LightGreen {
  
  package "Сетевая инфраструктура" {
    component "VPC/Виртуальная сеть" as VPC
    component "Подсети" as SUBNETS
    component "Фаерволы/NSG" as FIREWALL
    component "Балансировщики нагрузки" as LOAD_BALANCER
    component "VPN/Gateway" as VPN
    component "DNS/Zones" as DNS
  }
  
  package "Безопасность и доступ" {
    component "IAM/RBAC роли" as IAM
    component "Security Groups" as SEC_GROUPS
    component "Key Vault/Secrets Manager" as KEY_VAULT
  }
  
  package "Управляемые сервисы" {
    component "Управляемые БД\n(PostgreSQL/MySQL)" as MANAGED_DB
    component "Облачный DWH\n(Synapse/BigQuery)" as CLOUD_DWH
    component "Object Storage\n(S3/Blob Storage)" as OBJECT_STORAGE
    component "Управляемый Kubernetes\n(AKS/EKS/GKE)" as MANAGED_K8S
  }
  
  package "Вычислительные ресурсы" {
    component "Виртуальные машины\n(базовый образ)" as VMS
    component "Диски/Storage" as DISKS
    component "Группы автомасштабирования" as AUTO_SCALE
  }
}

package "Компоненты ручного развертывания/настройки" #Pink {
  
  package "Миграция легаси-систем" {
    component "SQL Server 2008 R2\n(временная система)" as SQL2008
    component "Миграция данных\nи бизнес-логики" as DATA_MIGRATION
    component "PowerBuilder приложения" as POWERBUILDER
  }
  
  package "Конфигурация приложений" {
    component "Настройка приложений\nи middleware" as APP_CONFIG
    component "Мониторинг и алертинг\n(тонкая настройка)" as MONITORING
    component "Стратегии бэкапов\nи DRP" as BACKUP_DRP
  }
  
  package "Специфичные сервисы" {
    component "ИИ-сервисы Python\n(специфичные зависимости)" as AI_SERVICES
    component "Финтех-сервисы\n(банковские интеграции)" as FINTECH_SERVICES
    component "Data Catalog\n(метаданные и политики)" as DATA_CATALOG
  }
}

package "Облачные провайдеры" {
  component "Microsoft Azure" as AZURE #LightGray
  component "Amazon Web Services" as AWS #LightGray
  component "Google Cloud Platform" as GCP #LightGray
}

' Связи Terraform
TERRAFORM --> VPC : Управляет
TERRAFORM --> IAM : Создает
TERRAFORM --> MANAGED_DB : Разворачивает
TERRAFORM --> VMS : Провизионирует
TERRAFORM --> MANAGED_K8S : Настраивает

' Связи CI/CD
GIT --> CICD : Триггерит
CICD --> TERRAFORM : Запускает
VAULT --> TERRAFORM : Предоставляет\nсекреты

' Связи облачных провайдеров
VPC --> AZURE : Развернуто в
MANAGED_DB --> AWS : Развернуто в
MANAGED_K8S --> GCP : Развернуто в

' Ручные процессы
component "DevOps команда" as DEVOPS #LightYellow
DEVOPS --> SQL2008 : Мигрирует
DEVOPS --> APP_CONFIG : Настраивает
DEVOPS --> AI_SERVICES : Интегрирует
DEVOPS --> FINTECH_SERVICES : Конфигурирует

' Легаси связи
SQL2008 --> DATA_MIGRATION : Временный\nисточник
DATA_MIGRATION --> MANAGED_DB : Переносит в

' Взаимодействие компонентов
VPC --> SUBNETS : Содержит
SUBNETS --> FIREWALL : Защищает
FIREWALL --> LOAD_BALANCER : Фильтрует трафик
LOAD_BALANCER --> VMS : Распределяет\nнагрузку
VMS --> DISKS : Использует
DISKS --> OBJECT_STORAGE : Резервирует в

IAM --> SEC_GROUPS : Определяет\nполитики
SEC_GROUPS --> MANAGED_DB : Защищает
MANAGED_DB --> CLOUD_DWH : Подает данные
CLOUD_DWH --> OBJECT_STORAGE : Хранит\nрезультаты

' Примечания
note top of TERRAFORM
  **Управление через Infrastructure as Code:**
  - Воспроизводимость окружений
  - Версионирование изменений
  - Автоматическое применение
end note

note right of DEVOPS
  **Ручные операции требуются для:**
  - Сложных миграций
  - Специфичных интеграций
  - Валидации безопасности
  - Конфигурации бизнес-логики
end note

note bottom of SQL2008
  **Временный компонент:**
  - Постепенная миграция
  - Параллельная работа
  - Вывод из эксплуатации
  через 6-12 месяцев
end note

@enduml
```

## Компонентная схема с указанием типа управления
### Компоненты, управляемые Terraform (Infrastructure as Code):
1. Сетевая инфраструктура
- VPC/Виртуальные сети и подсети
- Межсетевые экраны и группы безопасности
- Балансировщики нагрузки
- VPN-шлюзы и DNS-зоны
- Пиринговые соединения между VPC
2. Вычислительные ресурсы
- Виртуальные машины (базовые образы)
- Диски и хранилища
- Группы автомасштабирования
- Управляемые Kubernetes-кластеры
3. Управляемые сервисы
- Облачные БД (PostgreSQL, MySQL, Azure SQL)
- Data Warehouses (Synapse, BigQuery, Redshift)
- Object Storage (S3, Blob Storage, Cloud Storage)
- Очереди и брокеры сообщений
4. Безопасность и управление доступом
- IAM роли и политики
- Key Vault / Secrets Manager
- Мониторинг и логирование (базовая настройка)

### Компоненты для ручного развертывания/настройки:
1. Легаси-системы (временные)
- SQL Server 2008 R2 (во время миграции)
- PowerBuilder клиентские приложения
- Apache Camel шина данных
2. Конфигурация приложений
- Настройка middleware и бизнес-логики
- Конфигурационные файлы прилож

