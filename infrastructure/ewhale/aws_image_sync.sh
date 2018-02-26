#!/usr/bin/env bash

export PATH=~/.local/bin:$PATH
aws s3 sync s3://ewhale-shop-prod-attachment-cache/attachment /var/www/app/attachment
aws s3 sync s3://ewhale-shop-prod-attachment-cache/mediacache/attachment /var/www/web/media/cache/attachment