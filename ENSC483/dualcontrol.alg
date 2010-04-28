 ;############### Variables ###############
#define x1_hat q10
#define x2_hat q11
#define x1_sys q17
#define x2_sys q15

#define y_2 q87
#define y_last_2 q88

#define x1_sys_2 q85
#define x2_sys_2 q86

#define x1_hat_dot q70
#define x2_hat_dot q71

#define a_11 q5
#define a_12 q6
#define a_21 q7
#define a_22 q8

#define k_1 q9
#define k_2 q20
#define l_1 q21
#define l_2 q22

#define y q13
#define ts q14

#define y_last q50

#define x1_hatn q60
#define x2_hatn q61

#define k_1_w q62
#define k_2_w q63

#define magic_number q42

;############### Initialize ###############

x1_hat=0
x2_hat=0
x1_hatn=0
x2_hatn=0
x1_sys=0
x2_sys=0

y_last=0
y_last_2=0

a_11=-32
a_12=1.000000
a_21=-882.754369
a_22=-8
k_1=116690.2776
k_2=1489.454
l_1=32
l_2=249.670968

magic_number = -7
k_1_w=116690.2776
k_2_w=1489.45

ts=0.001768

control_effort1 = 0
control_effort2 = 0
;############### Control Loop ###############
begin
	y=enc2_pos/10000+2
	x1_sys = y
	x2_sys = ((y-y_last)/ts)
	y_last = y
	control_effort2 = (k_1_w*(x1_sys)+k_2_w*(x2_sys))/magic_number +5588

	y_2=enc1_pos/10000-2
	x1_sys_2 = y_2
	x2_sys_2 = ((y_2-y_last_2)/ts)
	y_last_2 = y_2
	control_effort1 = (k_1_w*(x1_sys_2)+k_2_w*(x2_sys_2))/5 -5588

	;control_effort2 = (k_1*(x1_hat)+k_2*(x2_hat))/15 +5588

	;x1_hatn = a_11*(x1_hat) + a_12*(x2_hat) + l_1*(y)
	;x2_hatn = a_21*(x1_hat) + a_22*(x2_hat) + l_2*(y-(x1_hat))
	;x1_hat=x1_hatn
	;x2_hat=x2_hatn

	x1_hat_dot = a_11*(x1_hat) + a_12*(x2_hat) - l_1*(y)
	x2_hat_dot = a_21*(x1_hat) + a_22*(x2_hat) - l_2*(y)

	x1_hat = y; x1_hat + ts*x1_hat_dot
	x2_hat = x2_hat + ts*x2_hat_dot 
end