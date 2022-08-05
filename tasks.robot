*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Desktop
Library             RPA.FileSystem
Library             RPA.FTP
Library             RPA.Archive
Library             RPA.Excel.Files
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Log In
    Open the intranet website
    ${orders_reps}=    Fill the form using CSV file
    Fill the form for each order    ${orders_reps}


*** Keywords ***
Log In
    ${secret}=    Get Secret    credentials
    Log    ${secret}[username]
    Log    ${secret}[password]

Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Fill the form for each order
    [Arguments]    ${orders_reps}
    Click Button    xpath://div[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Wait Until Element Is Visible    id:head
    Select From List By Value    id:head    ${orders_reps}[Head]
    IF    ${orders_reps}[Body] == 1
        Click Button    xpath://*[@id="id-body-1"]
    ELSE IF    ${orders_reps}[Body] == 2
        Click Button    xpath://*[@id="id-body-2"]
    ELSE IF    ${orders_reps}[Body] == 3
        Click Button    xpath://*[@id="id-body-3"]
    ELSE IF    ${orders_reps}[Body] == 4
        Click Button    xpath://*[@id="id-body-4"]
    ELSE IF    ${orders_reps}[Body] == 5
        Click Button    xpath://*[@id="id-body-5"]
    ELSE IF    ${orders_reps}[Body] == 6
        Click Button    xpath://*[@id="id-body-6"]
    END
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${orders_reps}[Legs]
    Input Text    id:address    ${orders_reps}[Address]
    Click Button    id:preview
    Click Button    id:order
    TRY
        Wait Until Element Is Visible    id:order-another    0.5s
    EXCEPT
        Double Click Element    id:order
    END
    Wait Until Element Is Visible    id:receipt
    ${order_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To pdf    ${order_results_html}    ${OUTPUT_DIR}${/}receipt${orders_reps}[Order number].PDF
    Capture Element Screenshot
    ...    xpath://*[@id="robot-preview"]
    ...    ${OUTPUT_DIR}${/}robot${orders_reps}[Order number].PNG
    ${receiptPDF}=    Open Pdf    ${OUTPUT_DIR}${/}receipt${orders_reps}[Order number].PDF
    ${robotPNG}=    Create List    ${OUTPUT_DIR}${/}robot${orders_reps}[Order number].PNG
    Add Files To Pdf    ${robotPNG}    ${OUTPUT_DIR}${/}receipt${orders_reps}[Order number].PDF
    Close Pdf    ${receiptPDF}
    Archive Folder With Zip    ${EXECDIR}${/}output    orders_pdf.zip    include=*.PDF
    Archive Folder With Zip    ${EXECDIR}${/}output    orders_png.zip    include=*.PNG
    Click Button    id:order-another

Fill the form using CSV file
    Add file input    orders    file_type=*.csv
    ${orders_reps}=    Read table from CSV    orders    header=True
    FOR    ${orders_reps}    IN    @{orders_reps}
        Fill the form for each order    ${orders_reps}
    END
    RETURN    ${orders_reps}
