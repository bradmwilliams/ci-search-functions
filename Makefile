build:
	go build .
.PHONY: build

deploy: build
	gcloud functions deploy TestPlatformResultsCISearchIndex \
		--project openshift-gce-devel --runtime go121 \
		--service-account search-index-gcs-writer@openshift-gce-devel.iam.gserviceaccount.com \
		--memory 128MB --timeout=15s --max-instances=10 \
		--trigger-resource test-platform-results --trigger-event google.storage.object.finalize
.PHONY: deploy

deploy-service-account:
	gcloud iam service-accounts create search-index-gcs-writer \
		--display-name search-index-gcs-writer \
		--description 'Allows ci-search-functions to update elements in the origin-ci-bucket that they own' \
		--project openshift-gce-devel
	gsutil -m iam ch \
		serviceAccount:search-index-gcs-writer@openshift-gce-devel.iam.gserviceaccount.com:objectCreator \
		serviceAccount:search-index-gcs-writer@openshift-gce-devel.iam.gserviceaccount.com:objectViewer \
		gs://test-platform-results
.PHONY: deploy-service-account

delete:
	gcloud functions delete TestPlatformResultsCISearchIndex \
		--project openshift-gce-devel
.PHONY: delete
