import sys, json

def print_error_message(result):
    error_message = ""
    failed_checks = False
    if result.get("results").get("parsingErrors"):
        print("::error::Parsing error file paths="+str(result.get("results").get("parsingErrors")))
        failed_checks = True
    if result.get("results").get("failedChecks"):
        for r in result.get("results").get("failedChecks"):
            line_range = "None"
            keys = ["filePath", "cvControl", "criticality", "remediation"]
            keys_names = ["File Name", "CV Control", "Criticality", "Remediation"]
            error_message += "::error::"
            for k in range(0, len(keys)):
                if r.get(keys[k]):
                    if keys[k] == "cvControl":
                        for c in r.get(keys[k]):
                            error_message += "Qualys CID=" + c.get("cid") + ", "
                            error_message += "Control Name=" + c.get("controlName")
                        error_message += ", "
                    else:
                        error_message += keys_names[k] + "=" + r.get(keys[k]) + ", "
                else:
                    if keys[k] == "cvControl":
                        error_message += "Qualys CID=None, Control Name=None, "
                    else:
                        error_message += keys_names[k] + "=None" + ", "
            if error_message.endswith(", "):
                error_message = error_message[:-2]

            print(error_message)
            failed_checks = True
            error_message = ""
    return failed_checks


def print_failed_checks(output):
    if output.get("status") != "FINISHED":
        exit(-1)
    failed_checks = False
    for result in output.get("result"):
        failed_checks = print_error_message(result)
    if failed_checks:
        exit(-1)


# Press the green button in the gutter to run the script.
if __name__ == '__main__':

    fp = open(sys.argv[1], "r")
    data = fp.read()
    raw_data = data
    fp.close()
    message = "The scan result is successfully retrieved. JSON output is as follows:"
    pos = data.find(message)
    pos += len(message)
    data = data[pos:]
    try:
        json_data = json.loads(data)
    except:
        print ("Error occured while scanning. Please find the error logs below :")
        print(raw_data)
    print_failed_checks(json_data)
