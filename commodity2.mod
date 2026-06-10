/*
    how_should_central_banks_respond_to_commodity_price_shocks.mod
    Baseline Dynare implementation of the log-linear model in Appendix B
    of Drechsel, McLeay, Tenreyro and Turri (2026).

    What this file does:
    - Implements the linearized equilibrium conditions in Appendix B
    - Lets you choose:
        * AE vs EM calibration
        * IMPORTER vs EXPORTER calibration
        * Policy rule: DIT / CPI / PEG / TAYLOR
    - Generates IRFs under a chosen shock process

    What this file does NOT yet do:
    - It does not implement the exact optimal commitment/welfare problem from Appendix C.
*/

@#define COUNTRY  = "AE"          // "AE" or "EM"
@#define EXPOSURE = "IMPORTER"    // "IMPORTER" or "EXPORTER"
@#define POLICY   = "DIT"         // "DIT", "CPI", "PEG", "TAYLOR"

// ------------------------------------------------------------
// 1. Variables
// ------------------------------------------------------------
var
    c c_h c_f c_h_star c_nc c_tildec
    n y_h x_tildec m_h y_c
    p p_h p_f p_tildec p_nc p_c
    p_star p_h_star p_f_star
    tau s
    w wr omega
    pi pi_h pi_star
    mc_r mrs
    i e
    riskprem b
    a_h a_c c_star i_star
    p_c_star p_tildec_star p_nc_star
;

varexo
    eps_ah eps_ac eps_cstar eps_istar
    eps_pcstar eps_ptcstar eps_pncstar
;

// ------------------------------------------------------------
// 2. Parameters
// ------------------------------------------------------------
parameters
    alpha alpha_c mu nu eta vartheta sigma phi beta
    theta delta epsilon chi
    kappa kappa_w
    phi_c_rp phi_tildec_rp phi_B_rp
    s_cstar s_m s_c
    rho_ah rho_ac rho_cstar rho_istar rho_pcstar rho_ptcstar rho_pncstar
    rho_i_m phi_pi phi_y
    disc
;

// ------------------------------------------------------------
// 3. Common calibration (Tables 1 and 2)
// ------------------------------------------------------------

// Home bias: 1-alpha = 0.6
alpha     = 0.4;

// Preferences / nominal rigidities
phi       = 1;
beta      = 0.9963;
theta     = 0.75;      // 1-theta = 0.25
delta     = 0.75;      // 1-delta = 0.25
epsilon   = 6;
chi       = 4;
nu        = 0.6;

// Baseline Cole-Obstfeld case used throughout most results
sigma     = 1;
eta       = 1;
vartheta  = 1;

// Slopes reported in Table 2
kappa     = 0.08426;
kappa_w   = 0.01685;

// Simple AR(1) persistence placeholders for exogenous processes
// (the paper shocks are temporary; these can be adjusted freely)
rho_ah      = 0.50;
rho_ac      = 0.50;
rho_cstar   = 0.50;
rho_istar   = 0.50;
rho_pcstar  = 0.50;
rho_ptcstar = 0.50;
rho_pncstar = 0.50;

// Optional Taylor rule parameters (only used if POLICY="TAYLOR")
rho_i_m   = 0.70;
phi_pi    = 1.50;
phi_y     = 0.10;

// ------------------------------------------------------------
// 4. Country-specific calibration (Table 1)
// ------------------------------------------------------------
@#if COUNTRY == "AE"
    phi_c_rp      = 0.0002;
    phi_tildec_rp = 0.0002;
    phi_B_rp      = 0.0028;
    s_cstar       = 0.30;
@#elseif COUNTRY == "EM"
    phi_c_rp      = 0.20;
    phi_tildec_rp = 0.20;
    phi_B_rp      = 2.80;
    s_cstar       = 0.0003;
@#else
    @#error "COUNTRY must be AE or EM"
@#endif

// ------------------------------------------------------------
// 5. Exposure-specific calibration (Table 1)
// ------------------------------------------------------------
@#if EXPOSURE == "EXPORTER"
    mu      = 0.001;
    alpha_c = 0.001;
@#elseif EXPOSURE == "IMPORTER"
    mu      = 0.20;
    alpha_c = 0.25;
@#else
    @#error "EXPOSURE must be IMPORTER or EXPORTER"
@#endif

// ------------------------------------------------------------
// 6. Steady-state shares
// ------------------------------------------------------------
// The paper endogenizes these from the steady state; for a practical linear file
// we compute s_c from the quadratic relationship in Appendix A and then use
// s_m = 1 - s_c - s_cstar.

// Compute disc and s_c using preprocessor (no model_local_variable needed outside model)
disc = (1-mu*nu)*(1-alpha)/(1-alpha*(1-nu)) - s_cstar;

// positive root of the quadratic in Appendix A
s_c = (disc + sqrt(disc^2 + 4*((1-alpha)/alpha)*(nu/(1-alpha*(1-nu)))*(s_cstar^2)) )/2;
s_m = 1 - s_c - s_cstar;

// ------------------------------------------------------------
// 7. Linearized model (Appendix B)
// ------------------------------------------------------------
model(linear);

// ------------------------
// Relative prices / inflation
// ------------------------
p       = alpha*p_f + (1-alpha)*p_h;                                   // (53)
p_f     = alpha_c*p_tildec + (1-alpha_c)*p_nc;                         // (54)
p_tildec= e + p_tildec_star;                                           // (55)
p_nc    = e + p_nc_star;                                               // (55)
p_c     = e + p_c_star;                                                // (55)
p_star  = p_nc_star;                                                   // (56)
p_h_star= p_h - e;                                                     // from p_h = e + p_h_star
p_f_star= alpha_c*p_tildec_star + (1-alpha_c)*p_nc_star;              // implied foreign import basket
tau     = p_f - p_h;                                                   // (57)
s       = e + p_star - p;                                              // (58) equivalent definition

pi      = p - p(-1);                                                   // from (60)
pi_h    = p_h - p_h(-1);                                               // from (60)
pi_star = p_star - p_star(-1);                                         // from (60)
omega   = w - w(-1);                                                   // from (61)
wr      = w - p;                                                       // (62)

// ------------------------
// Resource constraint / demand
// ------------------------
y_h      = s_c*c_h + s_cstar*c_h_star + s_m*m_h;                       // (59)

c_h      = -eta*(p_h - p) + c;                                         // (64)
c_f      = -eta*(p_f - p) + c;                                         // (65)
c_h_star = -eta*(p_h_star - p_star) + c_star;                          // (66)
c_nc     = -vartheta*(p_nc - p_f) + c_f;                               // (67)

// Practical correction of OCR issue in extracted eq. (68):
// standard CES demand for imported commodity within foreign bundle
c_tildec = -vartheta*(p_tildec - p_f) + c_f;

// ------------------------
// Household block
// ------------------------
omega = kappa_w*(mrs - wr) + beta*omega(+1);                           // (69)
mrs   = phi*n + sigma*c;                                               // (70)
sigma*c = -(i - pi(+1)) + sigma*c(+1);                                 // (71)
i - pi(+1) = i_star - pi_star(+1) + s(+1) - s + riskprem;             // (72)
riskprem = phi_tildec_rp*p_tildec_star - phi_c_rp*p_c_star - phi_B_rp*b; // (73)

beta*b - b(-1) =
      s_m*nu*(alpha*s_c)/(alpha*s_c + s_cstar)*(y_c + p_c_star)
    + s_cstar*(c_h_star + p_h_star)
    - mu*(alpha*s_c)/(alpha*s_c + s_cstar)*(x_tildec + p_tildec_star)
    - (alpha*s_c)/(1-alpha)*(c_f + p_f_star);                          // (74)

// ------------------------
// Domestic goods production
// ------------------------
y_h    = a_h + (1-mu)*n + mu*x_tildec;                                 // (75)
pi_h   = kappa*mc_r + beta*pi_h(+1);                                   // (76)
mc_r   = (1-mu)*w + mu*p_tildec - a_h - p_h;                           // (77)
x_tildec + p_tildec = n + w;                                           // (78)

// ------------------------
// Commodity export sector
// ------------------------
y_c = a_c + nu*m_h;                                                    // (79)
(1-nu)*m_h = a_c + p_c - p_h;                                          // (80)

// ------------------------
// Exogenous processes
// ------------------------
a_h           = rho_ah*a_h(-1)           + eps_ah;
a_c           = rho_ac*a_c(-1)           + eps_ac;
c_star        = rho_cstar*c_star(-1)     + eps_cstar;
i_star        = rho_istar*i_star(-1)     + eps_istar;
p_c_star      = rho_pcstar*p_c_star(-1)  + eps_pcstar;
p_tildec_star = rho_ptcstar*p_tildec_star(-1) + eps_ptcstar;
p_nc_star     = rho_pncstar*p_nc_star(-1)+ eps_pncstar;

// ------------------------
// Monetary policy closure
// ------------------------
@#if POLICY == "DIT"
    pi_h = 0;
@#elseif POLICY == "CPI"
    pi = 0;
@#elseif POLICY == "PEG"
    e = 0;
@#elseif POLICY == "TAYLOR"
    i = rho_i_m*i(-1) + (1-rho_i_m)*(phi_pi*pi + phi_y*y_h);
@#else
    @#error "POLICY must be DIT, CPI, PEG, or TAYLOR"
@#endif

end;

// ------------------------------------------------------------
// 8. Initialization
// ------------------------------------------------------------
initval;
    c = 0;
    c_h = 0;
    c_f = 0;
    c_h_star = 0;
    c_nc = 0;
    c_tildec = 0;
    n = 0;
    y_h = 0;
    x_tildec = 0;
    m_h = 0;
    y_c = 0;

    p = 0;
    p_h = 0;
    p_f = 0;
    p_tildec = 0;
    p_nc = 0;
    p_c = 0;
    p_star = 0;
    p_h_star = 0;
    p_f_star = 0;
    tau = 0;
    s = 0;

    w = 0;
    wr = 0;
    omega = 0;
    pi = 0;
    pi_h = 0;
    pi_star = 0;
    mc_r = 0;
    mrs = 0;

    i = 0;
    e = 0;
    riskprem = 0;
    b = 0;

    a_h = 0;
    a_c = 0;
    c_star = 0;
    i_star = 0;
    p_c_star = 0;
    p_tildec_star = 0;
    p_nc_star = 0;
end;

steady;
check;

// ------------------------------------------------------------
// 9. Shocks
// ------------------------------------------------------------
// By default: a 10% commodity import price shock (energy-price shock).
// Set other shocks to zero.
// For an export-price shock, set stderr eps_pcstar = 0.10 and eps_ptcstar = 0.
// For correlated import/export shocks, set both.

shocks;
    var eps_ptcstar; stderr 0.10;      // 10% import commodity price shock
    var eps_pcstar;  stderr 0.00;
    var eps_pncstar; stderr 0.00;
    var eps_ah;      stderr 0.00;
    var eps_ac;      stderr 0.00;
    var eps_cstar;   stderr 0.00;
    var eps_istar;   stderr 0.00;
end;

// ------------------------------------------------------------
// 10. Simulation
// ------------------------------------------------------------

stoch_simul(order=1, irf=12, nograph);