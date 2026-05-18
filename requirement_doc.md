## Master Data Management

### Manage Employee Master
- Description: Maintain the list of employees who can be assigned to project activities and action points. Employees are referenced from tasks, activities and check-list action points.
- Data points: Employee Code, Employee Name, Designation (dropdown: Project Manager / Site Engineer / Architect / Civil Engineer / Electrical Engineer / Plumbing Engineer / Contractor / Supervisor / Quality Inspector / Safety Officer / Procurement Officer / Liaison Officer / Sales Manager / Other), Department (dropdown: Planning / Design / Construction / Procurement / Sales & Marketing / Legal & Liaison / Quality / Safety / Finance / Admin), Email, Mobile Number, Reporting Manager, Date of Joining, Status (Active / Inactive), Remarks.
- Business rules: Employee Code is mandatory and unique. Email must be a valid format and unique. Mobile Number must be 10 digits. Reporting Manager must be an existing Active employee. Inactive employees cannot be assigned to new action points.
- Actions: Search, Add, Edit, Delete (soft-delete by toggling Status to Inactive when references exist).
- Additional data management: On deactivation, open action points assigned to the employee are flagged for reassignment.

### Manage Project Location Master
- Description: Maintain the list of project sites / locations used to tag projects.
- Data points: Location Code, Location Name, Address Line 1, Address Line 2, City, State (dropdown of Indian states), Pin Code, Country (default India), Latitude, Longitude, Status (Active / Inactive).
- Business rules: Location Code is mandatory and unique. Pin Code must be 6 digits numeric. Latitude/Longitude, if entered, must be within valid ranges.
- Actions: Search, Add, Edit, Delete.
- Additional data management: None.

## Project Setup & Planning

### Manage Project
- Description: Create and maintain real-estate development projects. Each project is the top-level container of phases, tasks, activities and action points.
- Data points: Project Code, Project Name, Project Type (dropdown: Residential Apartment / Residential Villa / Commercial Office / Commercial Retail / Mixed-Use / Township / Plotted Development / Redevelopment), Project Category (dropdown: Affordable / Mid-Segment / Premium / Luxury / Ultra-Luxury), Priority (dropdown: Low / Medium / High / Critical), Status (dropdown: Draft / Planned / In-Progress / On-Hold / Completed / Cancelled), Project Location, Land Area (Sq.Ft), Built-up Area (Sq.Ft), Number of Towers, Number of Units, Planned Start Date, Planned End Date, Actual Start Date, Actual End Date, Estimated Budget, Approved Budget, Project Manager (Employee), RERA Number, Approval Authority, Description, Remarks.
- Business rules: Project Code is mandatory and unique. Planned End Date must be on or after Planned Start Date. Approved Budget cannot exceed Estimated Budget by more than 20% without an Approve action. A project cannot be marked Completed unless all phases are Completed or Cancelled. Cancelled projects become read-only.
- Actions: Search, Add, Edit, Delete, Submit-for-Approval, Approve, Cancel.
- Additional data management: On Submit-for-Approval, send notification to the approver role. On Approve, set Status to Planned and stamp approval date/user. On Cancel, cascade-cancel all open phases, tasks, activities and action points.

### Manage Project Phase
- Description: Define phases under a project (e.g., Land Acquisition, Design, Approvals, Construction, Handover). Phases are sequenced and have their own timelines and status.
- Data points: Project, Phase Code, Phase Name, Phase Type (dropdown: Land Acquisition / Feasibility / Design & Planning / Statutory Approvals / Pre-Construction / Foundation / Structure / MEP / Finishing / External Development / Handover / Post-Handover), Sequence Number, Planned Start Date, Planned End Date, Actual Start Date, Actual End Date, Phase Owner (Employee), Status (dropdown: Not-Started / In-Progress / On-Hold / Completed / Cancelled), Weightage % (contribution to project progress), Remarks.
- Business rules: Phase Code is unique within a project. Sequence Number is mandatory and unique within a project. Sum of Weightage % across non-cancelled phases of a project should equal 100. Planned End Date >= Planned Start Date. A phase cannot be Completed if it has open tasks.
- Actions: Search, Add, Edit, Delete, Cancel.
- Additional data management: On Phase status change to Completed, recompute project % complete using phase weightages. On Cancel, cascade-cancel child tasks.

### Manage Task
- Description: Define tasks within a phase. Tasks are the work breakdown of a phase and contain activities.
- Data points: Project, Phase, Task Code, Task Name, Task Category (dropdown: Civil / Structural / Architectural / MEP - Electrical / MEP - Plumbing / MEP - HVAC / Interior / External / Approvals / Procurement / Quality / Safety / Handover / Documentation), Priority (dropdown: Low / Medium / High / Critical), Planned Start Date, Planned End Date, Actual Start Date, Actual End Date, Assigned To (Employee), Status (dropdown: Not-Started / In-Progress / On-Hold / Completed / Cancelled), % Complete, Predecessor Task, Weightage % within phase, Remarks.
- Business rules: Task Code is unique within a phase. Planned End Date >= Planned Start Date. Predecessor task must belong to the same project. A task cannot be set to In-Progress if its predecessor is not Completed. % Complete must be 0–100 and 100 only when Status is Completed. Sum of Weightage % across non-cancelled tasks within a phase should equal 100.
- Actions: Search, Add, Edit, Delete, Cancel.
- Additional data management: On task completion, recompute phase % complete from task weightages; on phase recompute, update project % complete.

### Manage Activity
- Description: Define activities within a task. Each activity has a check-list of action points.
- Data points: Project, Phase, Task, Activity Code, Activity Name, Activity Type (dropdown: Survey / Drawing / Approval / Procurement / Execution / Inspection / Testing / Handover / Documentation / Meeting), Priority (dropdown: Low / Medium / High / Critical), Planned Start Date, Planned End Date, Actual Start Date, Actual End Date, Assigned To (Employee), Status (dropdown: Not-Started / In-Progress / On-Hold / Completed / Cancelled), % Complete, Remarks.
- Business rules: Activity Code is unique within a task. Planned End Date >= Planned Start Date. Activity % Complete is derived from completed action points (count of Done action points / total non-cancelled action points). An activity cannot be Completed unless all its action points are Done or Cancelled.
- Actions: Search, Add, Edit, Delete, Cancel.
- Additional data management: On action-point status change, automatically recompute activity % complete and roll up to task and phase.

### Manage Action Point (Check-list)
- Description: Maintain the check-list of action points under an activity. Each action point has a single assigned employee and a status.
- Data points: Project, Phase, Task, Activity, Action Point Sequence, Action Point Description, Assigned Employee, Due Date, Completed Date, Status (dropdown: Pending / In-Progress / Done / Blocked / Cancelled), Blocking Reason, Attachment, Remarks.
- Business rules: Action Point Description and Assigned Employee are mandatory. Due Date must lie between the parent activity's Planned Start and End Dates. Status Done requires Completed Date. Status Blocked requires Blocking Reason. Cancelled action points are excluded from progress computation.
- Actions: Search, Add, Edit, Delete, Mark-Done, Mark-Blocked, Cancel.
- Additional data management: On Mark-Done, stamp Completed Date and trigger notification to the Activity owner. On Mark-Blocked, send notification to the Task owner and Project Manager. Recompute parent activity/task/phase/project % complete.

## Project Execution & Monitoring

### Log Daily Progress Update
- Description: Capture daily progress notes against a task or activity, with optional photos.
- Data points: Project, Phase, Task, Activity (optional), Update Date, Reported By (Employee), Progress Notes, Issues Faced, % Complete Update, Photographs (attachments).
- Business rules: Update Date cannot be in the future. % Complete Update must be >= existing % Complete of the activity/task. Reported By must be an Active employee.
- Actions: Search, Add, Edit, Delete.
- Additional data management: On save, update the % Complete of the linked activity/task and trigger roll-up to phase and project. Send notification to the Project Manager if Issues Faced is non-blank.

### Manage Project Issue / Risk
- Description: Capture and track issues or risks that arise during project execution.
- Data points: Project, Phase, Task (optional), Issue Type (dropdown: Issue / Risk), Category (dropdown: Design / Approval / Material / Manpower / Equipment / Quality / Safety / Financial / Statutory / Weather / Other), Priority (dropdown: Low / Medium / High / Critical), Reported Date, Reported By, Description, Mitigation Plan, Owner (Employee), Target Closure Date, Status (dropdown: Open / In-Progress / Mitigated / Closed / Cancelled), Closure Date, Closure Remarks.
- Business rules: Target Closure Date >= Reported Date. Status Closed requires Closure Date and Closure Remarks. Critical issues cannot be deleted, only Cancelled.
- Actions: Search, Add, Edit, Delete, Close, Cancel.
- Additional data management: On Add of a Critical issue, send notification and email to the Project Manager. On Close, send notification to Reported By.

## Information Outputs

### Visual: Project Portfolio Grid (V)
- Visualization: Grid.
- Criteria: Project Type, Project Category, Status, Priority, Project Manager, Planned Start Date Range, Location.
- Data points: Project Code, Project Name, Project Type, Category, Priority, Status, Project Manager, Planned Start, Planned End, % Complete, Approved Budget, Location.
- Drill-down: Project Code hyperlink to Project Smart Page.

### Visual: Phase Progress Pivot (V)
- Visualization: Pivot.
- Criteria: Project, Phase Type, Status.
- Rows: Project Name. Columns: Phase Type. Values: % Complete (avg), Count of Tasks.
- Drill-down: Cell drill to filtered Task list.

### Visual: Task Status Distribution (V)
- Visualization: Stacked-Column-Chart.
- Criteria: Project, Phase, Task Category, Date Range.
- X-Axis: Phase. Y-Axis: Count of Tasks. Stack: Status.

### Visual: Action Point Aging (V)
- Visualization: Bar-Chart.
- Criteria: Project, Assigned Employee, Status, Due Date Range.
- X-Axis: Assigned Employee. Y-Axis: Count of Pending/Blocked action points bucketed by aging (0-7, 8-15, 16-30, >30 days).

### Visual: Project Timeline Gantt (V)
- Visualization: Grid (Gantt-style timeline).
- Criteria: Project, Phase, Date Range.
- Data points: Phase / Task / Activity hierarchy with Planned vs Actual dates and % Complete bar.

### Visual: Issue & Risk Card (V)
- Visualization: Card.
- Criteria: Project, Date Range.
- Cards: Open Issues, Critical Issues, Overdue Issues, Mitigated This Month.

### Visual: Budget vs Actual (V)
- Visualization: Column-Chart.
- Criteria: Project, Phase.
- X-Axis: Phase. Y-Axis: Amount. Series: Approved Budget vs Actual Spend (sourced from progress data).

### Visual: Employee Workload (V)
- Visualization: Pivot.
- Criteria: Project, Department, Status.
- Rows: Employee. Columns: Status. Values: Count of Action Points.

### Visual: Top KPI Cards (V)
- Visualization: Card.
- Cards: Total Active Projects, Average Project % Complete, Tasks Due This Week, Overdue Action Points, Open Critical Issues.

### Report: Project Status Report (R)
- Layout: Pixel-perfect printable status report grouped by Project > Phase > Task, with header (project meta, RERA, manager), footer (page numbers, signature block for Project Manager and Sponsor), and grand-total summary.
- Criteria: Project, As-of Date.
- Grouping: Level 1 - Project (sub-total: % complete, budget, count of tasks), Level 2 - Phase (sub-total: % complete, count of tasks), Level 3 - Task.
- Columns: Code, Name, Planned Start, Planned End, Actual Start, Actual End, Assigned To, Status, % Complete, Remarks.

## Dashboards

### Dashboard: Project Manager Dashboard (D)
- Role: Project Manager.
- Criteria: Project (multi-select, default = projects where logged-in user is Project Manager), Date Range (default = current quarter).
- Top KPI Cards (V - Card): Active Projects, Avg % Complete, Tasks Due This Week, Overdue Action Points, Open Critical Issues.
- Visuals:
  - Phase Progress Pivot (V - Pivot) filtered by selected projects.
  - Task Status Distribution (V - Stacked-Column-Chart).
  - Action Point Aging (V - Bar-Chart).
  - Project Timeline Gantt (V - Grid).
  - Issue & Risk Card (V - Card).

### Dashboard: Executive / Promoter Dashboard (D)
- Role: Executive / Promoter.
- Criteria: Project Type, Project Category, Status (default Active), Location.
- Top KPI Cards (V - Card): Total Active Projects, Portfolio % Complete, Total Approved Budget, Total Open Critical Issues, Projects Delayed.
- Visuals:
  - Project Portfolio Grid (V - Grid).
  - Budget vs Actual (V - Column-Chart).
  - Project Status by Type (V - Pie-Chart, slices = Status, filter = Project Type).
  - Projects by Location (V - Map / Bubble-Chart).

### Dashboard: Site Engineer Dashboard (D)
- Role: Site Engineer / Activity Owner.
- Criteria: Project (default = projects assigned), Date Range (default = current week).
- Top KPI Cards (V - Card): My Open Action Points, Due Today, Overdue, Blocked, Completed This Week.
- Visuals:
  - My Action Points (V - Grid) filtered by Assigned Employee = logged-in user.
  - My Activities Progress (V - Bar-Chart).
  - My Issues (V - Grid) where Owner = logged-in user.

## Smart Pages

### Smart Page: Project Workspace (S)
- Purpose and audience: A dedicated workspace per project for the Project Manager and site team to view and manage all phases, tasks, activities and action points of the project from a single page.
- Key sections / blocks:
  - Hero block: Project Name, Project Code, Status badge, % Complete progress bar, Project Manager, RERA, Location.
  - Callout strip: KPI cards for Open Action Points, Tasks Due This Week, Open Critical Issues, Days to Planned End.
  - Two-column grid:
    - Left column: Phase navigator (collapsible list of phases with % complete bars). Selecting a phase filters the right column.
    - Right column: Task & Activity board grouped by Task, each with its check-list of action points showing status chips and assigned employee avatars.
  - Embedded visual: Project Timeline Gantt (V) for the selected project.
  - Embedded visual: Action Point Aging (V) filtered to this project.
  - Content section: Recent Progress Updates feed (latest 10 progress logs with photos).
- Inline inputs and CTAs:
  - Inline status toggle on each action point (Pending / In-Progress / Done / Blocked) with optional remark.
  - Inline "Add Action Point" input under each activity (description + assigned employee + due date).
  - CTA "Add Phase" -> opens Project Phase Add form.
  - CTA "Add Task" -> opens Task Add form pre-filled with selected phase.
  - CTA "Log Progress Update" -> opens Daily Progress Update form pre-filled with project.
  - CTA "Report Issue" -> opens Project Issue Add form pre-filled with project.
  - CTA "Open Status Report (R)" -> runs Project Status Report for this project.

### Smart Page: Welcome / Home (S)
- Purpose and audience: Authenticated landing page for all internal users summarising what is happening across their projects.
- Key sections / blocks:
  - Hero: greeting with user name, current date, and quick links.
  - Feature grid: tiles for Projects, My Tasks, My Action Points, Issues, Reports.
  - Embedded visual: Top KPI Cards (V).
  - Embedded visual: My Action Points grid (V) filtered to logged-in user.
  - Callout: link to Help & FAQ.
- Inline inputs and CTAs:
  - Quick "Go to Project" search box -> navigates to selected Project Workspace.
  - CTA "Create New Project" -> Project Add form.

### Smart Page: Help & FAQ (S)
- Purpose and audience: In-app help for project teams on how to use the project management module.
- Key sections / blocks: Hero heading, paragraph intro, accordion FAQ blocks (How to create a project, How phases roll up, How to mark action points done, How status flows work), callout linking to support email.
- Inline inputs and CTAs: "Email Support" CTA opening mail client.

## External Website: Developer Corporate Site

- Purpose, audience, primary CTA: Public marketing site for the real-estate developer. Audience is prospective home buyers, channel partners, investors and media. Primary CTA is "Enquire Now" capturing buyer leads, with secondary CTA "Explore Projects".
- Custom domains: tenant subdomain (e.g., developer.proteusvision.com) and an optional vanity domain such as www.<developer-brand>.com.
- Marketing pages:

  - Home (S):
    - Hero block: brand tagline, hero image/video carousel of flagship projects, primary CTA "Enquire Now", secondary CTA "Explore Projects".
    - Feature grid: tiles for Residential, Commercial, Townships, Completed Projects.
    - Featured Projects section: cards (image, name, location, configuration, status) sourced from the public Projects API.
    - Why Choose Us callouts: years of experience, units delivered, RERA-registered, on-time delivery.
    - Testimonials block.
    - Newsroom strip: latest 3 news items.
    - Footer CTA: contact form embed.
    - Inline inputs: Enquiry mini-form (Name, Mobile, Email, Project of Interest).

  - About (S):
    - Hero: "About Us" heading and brand image.
    - Paragraph blocks: company story, vision, mission, values.
    - Leadership grid: photo + name + designation cards.
    - Milestones timeline.
    - CTA: "Contact Us".

  - Projects Overview (S):
    - Hero with filters (City, Type, Status: Ongoing / Completed / Upcoming).
    - Project card grid sourced from the public Projects API.
    - CTA on each card: "View Details".

  - Project Detail (S, one per public project; template-driven):
    - Hero: project name, location, configuration, RERA number, status badge.
    - Image/Video gallery block.
    - Highlights and amenities feature grid.
    - Floor plan and master plan image blocks.
    - Location map embed.
    - Specifications content block.
    - Sticky Enquiry form (Name, Mobile, Email, Configuration of Interest).
    - CTA: "Download Brochure", "Schedule Site Visit".

  - Pricing / Configurations (S):
    - Hero with project selector.
    - Configuration table block (Type, Carpet Area, Starting Price, Availability).
    - CTA: "Request Detailed Cost Sheet".

  - Blog / Newsroom Index (S):
    - Hero, post grid with image + title + date + excerpt, pagination.

  - Contact (S):
    - Hero, office address blocks, map embed.
    - Contact form (Name, Email, Mobile, Subject, Message, Interested Project) with submit CTA.
    - Channel partner registration CTA.

### API Requirements
- GET /api/public/projects — list public projects for Projects Overview and Home featured section. Params: city, type, status, limit, offset. Response: { items: [{ code, name, city, type, configuration, status, hero_image_url, rera_number, starting_price }], total }. Cache TTL: 600s.
- GET /api/public/projects/{code} — full project detail for Project Detail page. Response: { code, name, description, city, location:{lat,lng,address}, type, status, rera_number, configurations:[{type, carpet_area, starting_price, availability}], amenities:[], highlights:[], gallery:[{type,url,caption}], floor_plans:[{name,url}], master_plan_url, brochure_url }. Cache TTL: 600s.
- GET /api/public/news — list news/blog items for Newsroom. Params: limit, offset, tag. Response: { items: [{ slug, title, excerpt, cover_url, published_at, tags:[] }], total }. Cache TTL: 900s.
- GET /api/public/news/{slug} — full blog/news article. Response: { slug, title, body_html, cover_url, published_at, author, tags:[] }. Cache TTL: 900s.
- GET /api/public/testimonials — testimonials for Home. Response: { items:[{ name, designation, photo_url, quote, project_code }] }. Cache TTL: 3600s.
- GET /api/public/leadership — leadership team for About page. Response: { items:[{ name, designation, photo_url, bio }] }. Cache TTL: 3600s.
- POST /api/public/enquiries — submit enquiry from Home, Project Detail, Pricing, Contact forms. Body: { name, mobile, email, project_code?, configuration?, message?, source_page }. Response: { enquiry_id, status }. Cache TTL: 0s (no cache).
- POST /api/public/contact — submit general contact form. Body: { name, email, mobile, subject, message, interested_project_code? }. Response: { ticket_id, status }. Cache TTL: 0s.
- POST /api/public/channel-partners — channel partner registration. Body: { firm_name, contact_person, mobile, email, city, rera_number? }. Response: { registration_id, status }. Cache TTL: 0s.