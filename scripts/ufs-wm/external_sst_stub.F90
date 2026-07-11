module external_sst_mod
  implicit none

  integer :: i_sst=1, j_sst=1

  logical :: forecast_mode = .false.
  logical :: use_ncep_sst = .false.

  real, allocatable :: sst_ncep(:,:), sst_anom(:,:)

end module external_sst_mod
