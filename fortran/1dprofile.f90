! A 1d profile model of river channel evolution
! based on J. Pelletier's C version. (2008)

Program onedprofile
    implicit none

    real :: transport, c, D, time, factor, maxx, totsed, delta_h, summ;
    integer :: bedrock, xc, y, lattice_size, check, i

    real, dimension (:), allocatable :: h, h_old
    
    open(unit=1,file="space1.txt")
    open(unit=2,file="time1.txt")

    c = 0.1
    D = 1.0
    lattice_size = 128 ! delta (D) is 1km, so this is a 128km basin
    bedrock = 16       ! bedrock-alluvial transition distance from divide

    allocate (h(lattice_size))
    allocate (h_old(lattice_size))

    xc = bedrock

    do i = 1, lattice_size
       if (i .gt. bedrock) then
          h(i) = 0.0
          h_old(i) = 0.0
          
          ! plot the initial condition
          ! write(...)
          write(1,fmt='(2(f9.5))') i/float(lattice_size),h(i)
       else
          h(i) = 1.0
          h_old(i) = 1.0
          ! write the value write(...)
          write(1,fmt='(2(f9.5))') i/float(lattice_size),h(i)
       endif
    enddo

    factor = 1.0
    time = 0.0
    check = 1000
    maxx = 0.0
   
    do while (time .lt. 100000.0)
       !print *, time
       if (time .gt. check) then
          summ = 0
          check = check + 10000
          do i=1, lattice_size
             summ = summ + h(i)
             ! write result
             write(1,fmt='(2(f9.5))') i/float(lattice_size),h(i)
          enddo

          ! write time sum/lattice-size
          ! write xc
          !print *, time, summ/lattice_size
          write(2,*) time, summ/lattice_size
          write(1,fmt='(2(f9.5))') xc/float(lattice_size),h(xc)
       endif
       maxx = 0.0
       totsed = 0.0
       delta_h = c * factor * (1/float(lattice_size)) * (h(1) - h(2))
       if (abs(delta_h) .gt. maxx) then
          maxx = abs(delta_h)
       endif
       h(1) = h(1) - delta_h
       totsed = delta_h

       do i=2, (lattice_size - 1)
          delta_h = c * factor * (i/float(lattice_size)) * (h_old(i) - h_old(i+1))
          totsed = totsed + delta_h
          transport = D * factor * (i/float(lattice_size)) * (h_old(i) - h_old(i+1))
          if ((transport .gt. (totsed + 0.01)) .and. (i .le. bedrock)) then
             xc = i
             if (abs(delta_h) .gt. maxx) then
                maxx = abs(delta_h)
             endif
             h(i) = h(i) - delta_h
          else
             delta_h = D * factor * ((i-1)/float(lattice_size)) * (h_old(i-1) - h_old(i)) &
                        - D * factor * (i/float(lattice_size)) * (h_old(i) - h_old(i+1))
             if (abs(delta_h) .gt. maxx) then
                maxx = abs(delta_h)
             endif
             h(i) = h(i) + delta_h
          endif
      enddo
      
      if (maxx .lt. 0.001) then
         do i=1, lattice_size
             h_old(i) = h(i)
             time = time + factor
         enddo
      else
          h(i) = h_old(i)
          factor = factor / 3.0
      endif
      if (maxx .lt. 0.0001) then
          factor = factor * 3.0
      endif
      print *, time, factor
  enddo
  deallocate(h)
  deallocate(h_old)
end program onedprofile
