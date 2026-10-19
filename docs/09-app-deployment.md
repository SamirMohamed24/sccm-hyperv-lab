# 9. Application deployment

Two apps are deployed in the lab and shown in Software Center on WIN10:

| App | Installer type | Deployment type |
|---|---|---|
| 7-Zip 26.04 | MSI | Windows Installer (detected automatically) |
| Notepad++ 8.x | EXE | Script Installer (configured manually) |

## The flow for every app

1. Put the installer in **its own folder** on a share.
2. **Create Application** with a deployment type and a detection method.
3. **Distribute Content** to the distribution point.
4. **Deploy** to a collection.
5. Test in **Software Center** and check the client logs.

## Content share

All sources live on SC01 in shared folders, one folder per app:

```
\\SC01\SCCMNotepadPlusPlus\npp.x64.exe
\\SC01\SCCMAPP\7-Zip\7z-x64.msi
```

![Notepad++ source folder shared as \\SC01\SCCMNotepadPlusPlus](../images/sc01/05-create-app-notepad/00-content-source-share.png)

- **Share permission:** Everyone = Read
- **NTFS:** SC01$ (and Everyone or Domain Computers) = Read

SCCM copies **everything** in the content folder to the clients, which is why each app gets its own folder.

---

## Notepad++ (EXE) – full walkthrough

### Test the silent install first

On WIN10, in an admin command prompt:

```
\\SC01\SCCMNotepadPlusPlus\npp.x64.exe /S
```

If it installs with no windows, the switch works. Uninstall it again before deploying:

```
"C:\Program Files\Notepad++\uninstall.exe" /S
```

### Create the application

1. **Software Library → Application Management → Applications → Create Application**.
2. Choose **Manually specify the application information**. *Automatically detect* only supports MSI, MSIX and similar formats, so an EXE isn't in that list.

   ![Automatic detection only lists formats SCCM can read](../images/sc01/05-create-app-notepad/01-create-app-type-list.png)

3. **Name:** `Notepad++`, **Publisher:** `Don Ho`, **Version:** `8.x`.

   ![Application general information](../images/sc01/05-create-app-notepad/02-notepad-general-info.png)

### Deployment type

**Add → Type: Script Installer → Manually specify the deployment type information**

![Script Installer deployment type](../images/sc01/05-create-app-notepad/03-script-installer-type.png)

| Tab | Field | Value |
|---|---|---|
| General | Name | `Notepad++ x64 EXE` |
| General | Administrator comments | `Silent install with /S` |
| Content | Content location | `\\SC01\SCCMNotepadPlusPlus\` (a **folder**, not the .exe) |
| Programs | Installation program | `npp.x64.exe /S` |
| Programs | Installation start in | Empty |
| Programs | Uninstall program | `"C:\Program Files\Notepad++\uninstall.exe" /S` |
| Programs | Run as 32-bit process on 64-bit clients | Unticked |

![Deployment type General tab](../images/sc01/05-create-app-notepad/07-deployment-type-general-tab.png)

![Deployment type Content tab with the share as content location](../images/sc01/05-create-app-notepad/08-deployment-type-content-tab.png)

![Deployment type Programs tab with install and uninstall commands](../images/sc01/05-create-app-notepad/09-deployment-type-programs-tab.png)

Put the uninstall command in **Uninstall program**, not in **Installation start in**. That field is a working directory, and a command there makes the install fail with `0x80070003` (path not found).

### Detection method

**Add Clause:**

| Field | Value |
|---|---|
| Setting Type | File System |
| Type | File |
| Path | `C:\Program Files\Notepad++` |
| File or folder name | `notepad++.exe` |
| Associated with a 32-bit application on 64-bit systems | **Unticked** |
| Rule | **The file system setting must exist on the target system** |

![Correct detection rule](../images/sc01/05-create-app-notepad/05-detection-rule.png)

Notes on the rule:

- **32-bit box unticked**, because the 64-bit app installs to `C:\Program Files`, not `C:\Program Files (x86)`.
- **Must exist** is enough for a simple check. The property rule (for example *Version ≥ 8.6.0*) is useful later for supersedence.

### User experience

| Field | Value |
|---|---|
| Installation behavior | Install for system |
| Logon requirement | Whether or not a user is logged on |
| Installation program visibility | Hidden |
| Maximum allowed run time | 60 minutes |

**Requirements** and **Dependencies** are left empty. A sensible requirement later: *Operating system = Windows 10/11 64-bit*, since the installer is 64-bit only.

![Application created](../images/sc01/05-create-app-notepad/06-create-app-complete.png)

### Distribute

**Right-click Notepad++ → Distribute Content → Add → Distribution Point → SC01.corp.lab**.

![Distribute Content in the application menu](../images/sc01/06-distribute-notepad/01-distribute-content-menu.png)

![SC01.CORP.LAB added as content destination](../images/sc01/06-distribute-notepad/02-distribute-dp-added.png)

![Distribution completed](../images/sc01/06-distribute-notepad/03-distribute-complete.png)

Check **Monitoring → Distribution Status → Content Status**. It turns green when the content is on the DP. Notepad++ got package ID **GBG00005** and shows **Success: 1**.

![Content status: Notepad++ distributed successfully](../images/sc01/06-distribute-notepad/04-content-status-success.png)

### Collection

**Assets and Compliance → Device Collections → Create Device Collection**

- Name: **Lab Clients**, limiting collection: **All Desktop and Server Clients** (only machines that have the SCCM client)

  ![Create the Lab Clients collection](../images/sc01/07-collection-lab-clients/01-create-collection-lab-clients.png)

- **Add Rule → Direct Rule**

  ![Add a direct rule](../images/sc01/07-collection-lab-clients/02-collection-add-direct-rule.png)

- Resource class *System Resource*, attribute *Name*, value `WIN10` (or `WIN%` with a wildcard), then tick **WIN10**

  ![Direct rule search with a wildcard](../images/sc01/07-collection-lab-clients/03-collection-direct-rule-search.png)

  ![WIN10 selected](../images/sc01/07-collection-lab-clients/04-collection-select-win10.png)

- Right-click the collection and choose **Update Membership**

![Lab Clients created with a direct rule for WIN10](../images/sc01/07-collection-lab-clients/05-collection-created.png)

A direct rule only adds the computers you tick. To add new machines automatically, use a **Query Rule** like `Name like 'WIN%'` instead.

### Deploy

**Right-click Notepad++ → Deploy**

![Deploy in the application menu](../images/sc01/08-deploy-notepad/01-deploy-menu.png)

1. **General → Collection → Browse → Lab Clients**.

   ![Select the Lab Clients collection](../images/sc01/08-deploy-notepad/02-deploy-select-collection.png)

2. **Content:** SC01 is already listed, because the content was distributed earlier.

   ![Content already on sc01.corp.lab](../images/sc01/08-deploy-notepad/03-deploy-content.png)

3. **Deployment Settings:** Action **Install**, Purpose **Available**, so the user installs it from Software Center. **Required** would install it automatically by a deadline.

   ![Action Install, purpose Available](../images/sc01/08-deploy-notepad/04-deploy-settings.png)

4. **Scheduling, User Experience, Alerts:** keep the defaults (available as soon as possible, no deadline, notifications in Software Center).
5. Check the **Summary** and click **Next → Close**.

   ![Deployment summary](../images/sc01/08-deploy-notepad/05-deploy-summary.png)

The deployment then shows under the application's **Deployments** tab. **Compliance %** starts at 0,0 and goes up as clients report back.

![Notepad++ deployed to Lab Clients as Available](../images/sc01/08-deploy-notepad/06-deployment-lab-clients.png)

### Test on WIN10

1. Run **Machine Policy Retrieval & Evaluation Cycle** and **Application Deployment Evaluation Cycle**.
2. Open **Software Center → Applications → Notepad++ → Install**.

![Software Center showing the deployed apps](../images/win10/04-software-center-apps.png)

After the install, Software Center shows **Status: Installed** and an **Uninstall** button.

![Notepad++ installed from Software Center](../images/sc01/08-deploy-notepad/07-software-center-installed.png)

### Client logs

`C:\Windows\CCM\Logs\` on WIN10:

| Log | Shows |
|---|---|
| `AppDiscovery.log` | Whether the detection method finds the app |
| `AppEnforce.log` | The install command and its exit code (0 = success). Created the first time an app install runs |
| `CAS.log`, `DataTransferService.log` | Content download problems |

Open the logs with **CMTrace** (`C:\Windows\CCM\CMTrace.exe` on the client). A successful install shows `Executing Command line ... with system context`, `exitcode: 0` and **Application discovered** afterwards.

---

## 7-Zip (MSI)

MSI is the easiest type, because SCCM reads the file for you.

1. **Create Application → Automatically detect information → Type: Windows Installer (\*.msi file)**.
2. **Location:** `\\sc01\SCCMAPP\7-Zip\7z-x64.msi`.
3. SCCM fills in the install command (`msiexec /i "7z-x64.msi" /q`) and the detection method (the MSI **product code**).
4. Set **Install behavior: Install for system**, then finish.
5. Distribute, deploy to **Lab Clients** and test, exactly as for Notepad++.

![7-Zip 26.04 application with one deployment type](../images/sc01/09-deploy-7zip/01-7zip-application.png)

---

## More apps to practice with

| Level | App | Silent install | Detection |
|---|---|---|---|
| MSI | Google Chrome Enterprise | MSI, detected automatically | Product code |
| MSI | Adobe Acrobat Reader | Enterprise MSI | Product code |
| EXE | VLC | `vlc-win64.exe /L=1033 /S` | `C:\Program Files\VideoLAN\VLC\vlc.exe` |
| EXE | Mozilla Firefox | `"Firefox Setup.exe" /S` | `C:\Program Files\Mozilla Firefox\firefox.exe` |

Advanced practice ideas are listed in [Next steps](next-steps.md).
