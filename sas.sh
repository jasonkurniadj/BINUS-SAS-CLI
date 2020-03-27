#!/bin/bash

header() {
	echo ""
	echo "         %%                         %%"
	echo "       %%    \$\$\$\$\$     @     \$\$\$\$\$    %%"
	echo "     %%     \$         @ @   $           %%"
	echo "   %%        \$\$\$\$\$   @   @   \$\$\$\$\$        %%"
	echo "     %%           \$ @@@@@@@       \$     %%"
	echo "       %%    \$\$\$\$\$ @       @ \$\$\$\$\$    %%"
	echo "         %%                         %%"
	echo ""
	echo -e "          \033[1m© Bina Nusantara IT Division\033[0m"
	echo ""
	echo "==============================================="
	echo "Last Update: $(stat -c %y sas.sh)"
	echo ""
	echo ""
}

help() {
	header

	echo -e "\033[1mCommand list:\033[0m"
	echo "	new service [service_name]		Create new service"
	# echo "	generate documentation			Generate Redoc documentation"
	echo ""
}

errorMsg() {
	echo -e "\033[31m$*\e[0m"
}

successMsg() {
	echo -e "\033[32m$*\e[0m"
}

warningMsg() {
	echo -e "\033[33m$*\e[0m"
}

generateServiceFile() {
	if [[ $2 = "config" ]]; then
		filename=$1/"config.json"
		touch $filename

		echo '{' >> $filename
		echo '	"service": {' >> $filename
		echo '		"name": "$1", ' >> $filename
		echo '		"description": ""' >> $filename
		echo '	},' >> $filename
		echo '	"endpoint": {' >> $filename
		echo '		"server": "localhost:8080",' >> $filename
		echo '		"elasticsearch": "localhost:9200",' >> $filename
		echo '		"tracing": "http://localhost:9411/api/v2/spans",' >> $filename
		echo '		"logging": "",' >> $filename
		echo '		"caching": "localhost:6379"' >> $filename
		echo '	},' >> $filename
		echo '	"connector": {' >> $filename
		echo '		"bcs": ""' >> $filename
		echo '	},' >> $filename
		echo '	"context": {' >> $filename
		echo '		"timeout": 15,' >> $filename
		echo '		"expiration": 600' >> $filename
		echo '	}' >> $filename
		echo '}' >> $filename
	elif [[ $2 = "transport" ]]; then
		filename=$1/"transport.go"
		touch $filename

		echo "package $1" >> $filename
		echo "" >> $filename
		echo "import (" >> $filename
		echo "	\"encoding/json\"" >> $filename
		echo "	\"io/ioutil\"" >> $filename
		echo "	\"log\"" >> $filename
		echo "	\"net/http\"" >> $filename
		echo "	\"os\"" >> $filename
		echo "	\"strconv\"" >> $filename
		echo "" >> $filename
		echo "	kitlog \"github.com/go-kit/kit/log\"" >> $filename
		echo "	\"github.com/gorilla/mux\"" >> $filename
		echo "	\"github.com/spf13/viper\"" >> $filename
		echo ")" >> $filename
		echo "" >> $filename
		echo "var RedisErr error" >> $filename
		echo "" >> $filename
		echo "func MakeHandler(logger kitlog.Logger) http.Handler {" >> $filename
		echo "	viper.SetConfigFile(`$1/config.json`)" >> $filename
		echo "	err := viper.ReadInConfig()" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		log.Fatalln(err)" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	logger.Log(\"service\", viper.GetString(\"service.name\"))" >> $filename
		echo "" >> $filename
		echo "	initTracer()" >> $filename
		echo "	RedisErr = initCaching()" >> $filename
		echo "	if RedisErr != nil {" >> $filename
		echo "		log.echoln(\"Redis Error: \" + RedisErr.Error())" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	router := mux.NewRouter()" >> $filename
		echo "	r := router.PathPrefix(\"<PREF_URL>\").Subrouter()" >> $filename
		echo "" >> $filename
		echo "	accessList, err := os.Open(\"./access-list.json\")" >> $filename
		echo "" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		log.echoln(\"error opening access-list.json\")" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	accList := new(Entities)" >> $filename
		echo "	byteValue, _ := ioutil.ReadAll(accessList)" >> $filename
		echo "" >> $filename
		echo "	json.Unmarshal(byteValue, &accList)" >> $filename
		echo "" >> $filename
		echo "	for i := 0; i < len(accList.Entities); i++ {" >> $filename
		echo "		if accList.Entities[i].EntityName == \"<ROOT_PACKAGE>\" {" >> $filename
		echo "			for j := 0; j < len(accList.Entities[i].ServiceList); j++ {" >> $filename
		echo "				if accList.Entities[i].ServiceList[j].ServiceName == \"$1\" {" >> $filename
		echo "					for k := 0; k < len(accList.Entities[i].ServiceList[j].AccessList); k++ {" >> $filename
		echo "						r.HandleFunc(\"/\"+accList.Entities[i].ServiceList[j].AccessList[k], <FUNC_HANDLER>).Methods(accList.Entities[i].ServiceList[j].AccessList[k]) " >> $filename
		echo "					}" >> $filename
		echo "					break" >> $filename
		echo "				}" >> $filename
		echo "			}" >> $filename
		echo "			break" >> $filename
		echo "		}" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	defer accessList.Close()" >> $filename
		echo "" >> $filename
		echo "	r.NotFoundHandler = http.Handler(notFoundHandler())" >> $filename
		echo "" >> $filename
		echo "	return r" >> $filename
		echo "}" >> $filename
		echo "" >> $filename
		echo "func notFoundHandler() http.Handler {" >> $filename
		echo "	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {" >> $filename
		echo "		errCode := http.StatusNotFound" >> $filename
		echo "		errMessage := "Not Found"" >> $filename
		echo "		errDescription := "Endpoint not found"" >> $filename
		echo "" >> $filename
		echo "		w.WriteHeader(errCode)" >> $filename
		echo "		w.Write([]byte(`{"code":"` + strconv.Itoa(errCode) + `", "message":"` + errMessage + `", "description":"` + errDescription + `"}`)) " >> $filename
		echo "		return" >> $filename
		echo "	})" >> $filename
		echo "}" >> $filename
	elif [[ $2 = "instrumenting" ]]; then
		filename=$1/"instrumenting.go"
		touch $filename

		echo "package $1" >> $filename
		echo "" >> $filename
		echo "import (" >> $filename
		echo "	\"log\"" >> $filename
		echo "" >> $filename
		echo "	\"contrib.go.opencensus.io/exporter/zipkin\"" >> $filename
		echo "	\"github.com/go-redis/redis\"" >> $filename
		echo "	stdzipkin \"github.com/openzipkin/zipkin-go\"" >> $filename
		echo "	zipkinhttp \"github.com/openzipkin/zipkin-go/reporter/http\"" >> $filename
		echo "	\"github.com/spf13/viper\"" >> $filename
		echo "	\"go.opencensus.io/trace\"" >> $filename
		echo ")" >> $filename
		echo "" >> $filename
		echo "var RedisClient *redis.Client" >> $filename
		echo "" >> $filename
		echo "func initTracer() {" >> $filename
		echo "	localEndpoint, err := stdzipkin.NewEndpoint(viper.GetString(\"service.name\"), viper.GetString(\"endpoint.server\"))" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		log.Fatalln(err)" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	reporter := zipkinhttp.NewReporter(viper.GetString(\"endpoint.tracing\"))" >> $filename
		echo "	exporter := zipkin.NewExporter(reporter, localEndpoint)" >> $filename
		echo "" >> $filename
		echo "	trace.RegisterExporter(exporter)" >> $filename
		echo "	trace.ApplyConfig(trace.Config{DefaultSampler: trace.AlwaysSample()})" >> $filename
		echo "}" >> $filename
		echo "" >> $filename
		echo "func initCaching() error {" >> $filename
		echo "	RedisClient = redis.NewClient(&redis.Options{" >> $filename
		echo "		Addr:     viper.GetString(\"endpoint.caching\")," >> $filename
		echo "		Password: \"\"," >> $filename
		echo "		DB:       0," >> $filename
		echo "	})" >> $filename
		echo "" >> $filename
		echo "	_, err := RedisClient.Ping().Result()" >> $filename
		echo "	return err" >> $filename
		echo "}" >> $filename
	elif [[ $2 = "model" ]]; then
		filename=$1/"model.go"
		touch $filename

		echo "package $1" >> $filename
		echo "" >> $filename
		echo "import \"encoding/xml\"" >> $filename
		echo "" >> $filename
		echo "type RequestModel struct {" >> $filename
		echo "}" >> $filename
		echo "" >> $filename
		echo "type ResponseXMLModel struct {" >> $filename
		echo "	XMLName xml.Name" >> $filename
		echo "	Body    struct {" >> $filename
		echo "		XMLName      xml.Name" >> $filename
		echo "		<RESPONSE_MODEL_NAME> <RESPONSE_MODEL_DATA_TYPE> \`xml:\"<RESPONSE_ROOT_TAG_NAME>\"\`" >> $filename
		echo "	}" >> $filename
		echo "}" >> $filename
		echo "" >> $filename
		echo "type Entities struct {" >> $filename
		echo "	Entities		[]Entity	\`json:\"entities\"\`" >> $filename
		echo "}" >> $filename
		echo "" >> $filename
		echo "type Entity struct {" >> $filename
		echo "	EntityName		string		\`json:\"name\"\`" >> $filename
		echo "	ServiceList		[]Service	\`json:\"serviceList\"\`" >> $filename
		echo "}" >> $filename
		echo "" >> $filename
		echo "type Service struct {" >> $filename
		echo "	ServiceName 		string 		\`json:\"serviceName\"\`" >> $filename
		echo "	Description			string		\`json:\"description\"\`" >> $filename
		echo "	UrlString			string		\`json:\"urlString\"\`" >> $filename
		echo "	AccessList			[]string 	\`json:\"methodList\"\`" >> $filename
		echo "}" >> $filename
	elif [[ $2 = "endpoint" ]]; then
		filename=$1/"endpoint.go"
		touch $filename

		echo "package $1" >> $filename
		echo "" >> $filename
		echo "import (" >> $filename
		echo "	\"encoding/json\"" >> $filename
		echo "	\"io/ioutil\"" >> $filename
		echo "	\"log\"" >> $filename
		echo "	\"strings\"" >> $filename
		echo "	\"time\"" >> $filename
		echo "	\"net/http\"" >> $filename
		echo "	\"strconv\"" >> $filename
		echo "" >> $filename
		echo "	\"github.com/spf13/viper\"" >> $filename
		echo "	\"go.opencensus.io/trace\"" >> $filename
		echo ")" >> $filename
		echo "" >> $filename
		echo "func <FUNC_HANDLER>(w http.ResponseWriter, r *http.Request) {" >> $filename
		echo "	_, span := trace.StartSpan(r.Context(), strings.ToUpper(r.Method)+\" \"+r.URL.Path)" >> $filename
		echo "	defer span.End()" >> $filename
		echo "" >> $filename
		echo "	w.Header().Set(\"Content-Type\", \"text/json; charset=utf-8\")" >> $filename
		echo "	errCode := http.StatusInternalServerError" >> $filename
		echo "	errMessage := \"Internal Server Error\"" >> $filename
		echo "" >> $filename
		echo "	span.AddAttributes(" >> $filename
		echo "		trace.StringAttribute(\"API-Key\", r.Header.Get(\"API-Key\"))," >> $filename
		echo "		trace.Int64Attribute(\"Status-Code\", int64(errCode))," >> $filename
		echo "	)" >> $filename
		echo "" >> $filename
		echo "	reqBody, err := ioutil.ReadAll(r.Body)" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		errDescription := err.Error()" >> $filename
		echo "" >> $filename
		echo "		w.WriteHeader(errCode)" >> $filename
		echo "		w.Write([]byte(\`{\"code\":\"\` + strconv.Itoa(errCode) + \`\", \"message\":\"\` + errMessage + \`\", \"description\":\"\` + errDescription + \`\"}\`))" >> $filename
		echo "		return" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	cacheKey := r.URL.Path + \" \" + string(reqBody)" >> $filename
		echo "" >> $filename
		echo "	reqModel := new(RequestModel)" >> $filename
		echo "	err = json.Unmarshal(reqBody, &reqModel)" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		errDescription := err.Error()" >> $filename
		echo "" >> $filename
		echo "		w.WriteHeader(errCode)" >> $filename
		echo "		w.Write([]byte(\`{\"code\":\"\` + strconv.Itoa(errCode) + \`\", \"message\":\"\` + errMessage + \`\", \"description\":\"\` + errDescription + \`\"}\`))" >> $filename
		echo "		return" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	if RedisErr == nil {" >> $filename
		echo "		response, err := RedisClient.Get(cacheKey).Result()" >> $filename
		echo "		if err == nil {" >> $filename
		echo "			log.Println(\"Get value from Redis.\")" >> $filename
		echo "			w.WriteHeader(http.StatusOK)" >> $filename
		echo "			w.Write([]byte(response))" >> $filename
		echo "			return" >> $filename
		echo "		}" >> $filename
		echo "	} else {" >> $filename
		echo "		log.Println(\"Redis Error in Endpoint: \" + RedisErr.Error())" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	response, err := <FUNC_SERVICE>(*reqModel, r)" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		errDescription := err.Error()" >> $filename
		echo "" >> $filename
		echo "		w.WriteHeader(errCode)" >> $filename
		echo "		w.Write([]byte(\`{\"code\":\"\` + strconv.Itoa(errCode) + \`\", \"message\":\"\` + errMessage + \`\", \"description\":\"\` + errDescription + \`\"}\`))" >> $filename
		echo "		return" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	respByteArr, err := json.MarshalIndent(response, \"\", \"	\")" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		errDescription := err.Error()" >> $filename
		echo "" >> $filename
		echo "		w.WriteHeader(errCode)" >> $filename
		echo "		w.Write([]byte(\`{\"code\":\"\` + strconv.Itoa(errCode) + \`\", \"message\":\"\` + errMessage + \`\", \"description\":\"\` + errDescription + \`\"}\`))" >> $filename
		echo "		return" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	if RedisErr == nil {" >> $filename
		echo "		expiration, err := strconv.Atoi(viper.GetString(\"context.expiration\"))" >> $filename
		echo "		if err != nil {" >> $filename
		echo "			errDescription := err.Error()" >> $filename
		echo "" >> $filename
		echo "			w.WriteHeader(errCode)" >> $filename
		echo "			w.Write([]byte(\`{\"code\":\"\` + strconv.Itoa(errCode) + \`\", \"message\":\"\` + errMessage + \`\", \"description\":\"\` + errDescription + \`\"}\`))" >> $filename
		echo "			return" >> $filename
		echo "		}" >> $filename
		echo "" >> $filename
		echo "		err = RedisClient.Set(cacheKey, respByteArr, time.Duration(time.Duration(expiration)*time.Second)).Err()" >> $filename
		echo "		if err != nil {" >> $filename
		echo "			log.Println(\"Cannot set value to Redis.\")" >> $filename
		echo "		} else {" >> $filename
		echo "			log.Println(\"Set value to Redis.\")" >> $filename
		echo "		}" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	span.AddAttributes(" >> $filename
		echo "		trace.Int64Attribute(\"Status-Code\", http.StatusOK)," >> $filename
		echo "	)" >> $filename
		echo "" >> $filename
		echo "	w.WriteHeader(http.StatusOK)" >> $filename
		echo "	w.Write(respByteArr)" >> $filename
		echo "}" >> $filename
	elif [[ $2 = "service" ]]; then
		filename=$1/"service.go"
		touch $filename

		echo "package $1" >> $filename
		echo "" >> $filename
		echo "import (" >> $filename
		echo "	\"bytes\"" >> $filename
		echo "	\"encoding/xml\"" >> $filename
		echo "	\"errors\"" >> $filename
		echo "	\"net/http\"" >> $filename
		echo "	\"strconv\"" >> $filename
		echo "	\"strings\"" >> $filename
		echo "	\"time\"" >> $filename
		echo "" >> $filename
		echo "	\"github.com/spf13/viper\"" >> $filename
		echo ")" >> $filename
		echo "" >> $filename
		echo "func <FUNC_SERVICE>(paramReq RequestModel, r *http.Request) (<RESPONSE_MODEL>, error) {" >> $filename
		echo "	respModel := new(<RESPONSE_MODEL>)" >> $filename
		echo "" >> $filename
		echo "	url := viper.GetString(\"connector.bcs\") + \"<SUFFIX_WSDL>\"" >> $filename
		echo "	payload := []byte(strings.TrimSpace(\`" >> $filename
		echo "		<XML_PAYLOAD_TAG>" >> $filename
		echo "	\`))" >> $filename
		echo "	soapAction := \"<SERVICE_OPERATION>.<OPERATION_VERSION>\"" >> $filename
		echo "	httpMethod := \"<HTTP_METHOD>\"" >> $filename
		echo "" >> $filename
		echo "	reqHTTP, err := http.NewRequest(httpMethod, url, bytes.NewReader(payload))" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		return *respModel, errors.New(err.Error())" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	reqHTTP.Header.Set(\"Content-type\", \"text/xml\")" >> $filename
		echo "	reqHTTP.Header.Set(\"SOAPAction\", soapAction)" >> $filename
		echo "" >> $filename
		echo "	timeout, err := strconv.Atoi(viper.GetString(\"context.timeout\"))" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		return *respModel, errors.New(err.Error())" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	client := &http.Client{" >> $filename
		echo "		Timeout: time.Duration(time.Duration(timeout) * time.Second)," >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	resp, err := client.Do(reqHTTP)" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		return *respModel, errors.New(err.Error())" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	respModelAll := new(ResponseXMLModel)" >> $filename
		echo "	err = xml.NewDecoder(resp.Body).Decode(respModelAll)" >> $filename
		echo "	if err != nil {" >> $filename
		echo "		return *respModel, errors.New(err.Error())" >> $filename
		echo "	}" >> $filename
		echo "" >> $filename
		echo "	return respModelAll.Body.<RESPONSE_MODEL_NAME>, nil" >> $filename
		echo "}" >> $filename
	elif [[ $2 = "sample" ]]; then
		filename=$1/"reqSample.json"
		touch $filename

		echo '{' >> $filename
		echo '	"properties": {' >> $filename
		echo '		"<PARAM_NAME_1>": {' >> $filename
		echo '			"Type": "string",' >> $filename
		echo '			"Format": "text",' >> $filename
		echo '			"Example": "<EXAMPLE_PARAM_1>"' >> $filename
		echo '		},' >> $filename
		echo '		"<PARAM_NAME_2>": {' >> $filename
		echo '			"Type": "string",' >> $filename
		echo '			"Format": "text",' >> $filename
		echo '			"Example": "<EXAMPLE_PARAM_2>"' >> $filename
		echo '		},' >> $filename
		echo '		"<PARAM_NAME_N>": {' >> $filename
		echo '			"Type": "string",' >> $filename
		echo '			"Format": "text",' >> $filename
		echo '			"Example": "<EXAMPLE_PARAM_3>"' >> $filename
		echo '		}' >> $filename
		echo '	},' >> $filename
		echo '	"required": [' >> $filename
		echo '		"<PARAM_NAME_1>",' >> $filename
		echo '		"<PARAM_NAME_2>",' >> $filename
		echo '		"<PARAM_NAME_N>"' >> $filename
		echo '	],' >> $filename
		echo '	"type": "object"' >> $filename
		echo '}' >> $filename
	elif [[ $2 = "readme" ]]; then
		filename=$1/"README.md"
		touch $filename

		echo "# $1" >> $filename
		echo "\`This service is generated by BINUS-SAS-CLI.\`" >> $filename
		echo "" >> $filename
		echo "## Overview" >> $filename
		echo "..." >> $filename
		echo "" >> $filename
		echo "## Getting Started" >> $filename
		echo "..." >> $filename
		echo "" >> $filename
		echo "## Contributor" >> $filename
		echo "..." >> $filename
	fi
}

newService() {
	if [ -d "$1" ]; then
		errorMsg "$1 folder already exists."
	elif ! [[ $1 =~ ^[a-zA-Z_-]+$ ]]; then
		errorMsg "Invalid service name."
	else
		mkdir $1

		generateServiceFile $1 "config"
		generateServiceFile $1 "transport"
		generateServiceFile $1 "instrumenting"
		generateServiceFile $1 "model"
		generateServiceFile $1 "endpoint"
		generateServiceFile $1 "service"
		generateServiceFile $1 "sample"
		generateServiceFile $1 "readme"

		echo ""
		successMsg "Success to generate service $1."
	fi
}


if [[ $1 = "" ]]; then
	warningMsg "No parameter found"
elif [[ $1 = "new" ]]; then
	if [[ $2 = "" ]]; then
		warningMsg "Please input parameter."
	elif [[ $2 = "service" ]]; then
		if [[ $3 = "" ]]; then
			warningMsg "Please input service name."
		else
			newService $3
		fi
	else
		warningMsg "Invalid parameter."
	fi
elif [[ $1 = "generate" ]]; then
	if [[ $2 = "" ]]; then
		warningMsg "Please input parameter."
	elif [[ $2 = "documentation" ]]; then
		warningMsg "TODO: Generate something"
	else
		warningMsg "Invalid parameter."
	fi
elif [[ $1 = "help" ]]; then
	help
fi

read -p "Press [Enter] continue..."
